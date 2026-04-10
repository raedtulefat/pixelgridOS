# game.noodable.com — Deployment Summary (Flutter Web)

This document describes the final, correct, production-grade deployment process for the Flutter web app GameShell, hosted at https://game.noodable.com. This file documents decisions and end state only and intentionally omits intermediate experiments or abandoned approaches.

---

## High-level architecture

- Application type: Flutter Web (static)
- Server: Nginx
- OS: Ubuntu 24.04 (NoodableTux)
- Deployment user: deploy (non-root)
- TLS: Let’s Encrypt (Certbot)
- CI-ready: Yes (GitHub Actions)
- Build location: On the server

There is no backend service, no open application port, no PM2, and no systemd service.

---

## Directory layout (final convention)

The deployment uses a home-directory model owned entirely by the deploy user:

/home/deploy/game.noodable.com/
├── repo/        # Git repository (source of truth)
│   └── build/   # Transient build artifacts (NOT tracked in git)
└── www/         # Nginx-served static output

Rules:
- repo contains a clean git checkout and ephemeral build output
- www contains only files served by Nginx
- Build artifacts are generated on the server
- Nothing in build/ is committed to Git
- Everything is owned by deploy:deploy
- Nginx only reads files and does not own them

---

## Git and build strategy

- Repository: git@github.com:raedtulefat/game-shell.git
- Git transport on server: SSH
- Build output: build/web (generated, never committed)

Deployment branches:
- rogue-choices/staging → staging deploy
- rogue-choices/prod → production deploy

Feature and dev branches never deploy directly.

---

## Build command (server-side)

flutter build web --release

---

## Deployment command (authoritative)

rsync -av --delete build/web/ ../www/

This guarantees clean deploys, no stale assets, deterministic results, and parity with CI-driven deploys.

---

## DNS configuration (GoDaddy)

A record:
- Type: A
- Host: game
- Value: 173.34.95.207

www.game.noodable.com is intentionally not used.

---

## Nginx configuration (final)

File: /etc/nginx/sites-available/game.noodable.com

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name game.noodable.com;
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
    return 301 https://$host$request_uri;
}

# HTTPS server
server {
    listen 443 ssl;
    server_name game.noodable.com;
    ssl_certificate /etc/letsencrypt/live/game.noodable.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/game.noodable.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
    root /home/deploy/game.noodable.com/www;
    index index.html;
    location / {
        try_files $uri $uri/ /index.html;
    }
}

Enabled with:
ln -s /etc/nginx/sites-available/game.noodable.com /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx

---

## TLS / HTTPS

TLS is managed by Certbot:
certbot --nginx -d game.noodable.com

Results:
- Certificate issued and installed
- Auto-renewal enabled
- No manual cron jobs required

---

## Permissions model

Directory traversal:
chmod o+x /home/deploy

Web root permissions:
chmod -R 755 /home/deploy/game.noodable.com/www

---

## Git transport and authentication (server)

- The server repository uses SSH, not HTTPS
- Origin remote: git@github.com:raedtulefat/game-shell.git
- Authentication via repo-scoped deploy key
- Deploy key is read-only
- The server never pushes to GitHub

---

## CI / GitHub Actions deployment contract

Authentication:
- GitHub Actions connects to the server via SSH
- SSH user: deploy
- SSH key stored as GitHub Actions secret
- Server authenticates to GitHub using a read-only deploy key
- No password-based authentication is used

Build location:
- Builds are performed on the server
- GitHub runners do not build Flutter
- Flutter is installed and available in the deploy user PATH

Deployment entrypoint:
git checkout <deploy-branch>
git reset --hard
git clean -fd
git pull --ff-only origin <deploy-branch>
flutter build web --release
rsync -av --delete build/web/ ../www/

Where <deploy-branch> ∈ { rogue-choices/staging, rogue-choices/prod }

Trigger policy:
- Automatic deploy triggers on push to rogue-choices/staging and rogue-choices/prod
- Manual workflow_dispatch is allowed

Safety guarantees:
- Deployment fails if branch is not approved
- Working tree is reset and cleaned before pull
- Deployment fails if build/web is missing
- rsync --delete is mandatory
- Server working tree is disposable and stateless

---

## Final verification checklist

- HTTPS enabled
- Site loads at https://game.noodable.com
- Flutter rendering correct
- Pointer and keyboard input functional
- Static hosting verified
- CI-driven deploys succeed without manual steps

---

## Final decisions (intentional)

- Static Nginx hosting
- Home-directory deployment model
- Server-side builds
- Branch-based deployment using rogue-choices/staging and rogue-choices/prod
- SSH-based Git transport
- Repo-scoped read-only deploy keys
- Rsync-based atomic updates
- Certbot-managed TLS
- No PM2
- No systemd services
- No reverse proxy
- No exposed application ports

---

## Conclusion

This deployment is clean, minimal, secure, reproducible, and production-grade. This document represents the canonical and final deployment process for game.noodable.com.
