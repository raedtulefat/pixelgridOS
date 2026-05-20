# pixelgrid

A reusable pixelgrid built with Flutter and Flame.
  - Flutter: https://flutter.dev/docs/get-started/install/macos
  - Flame: https://github.com/flame-engine/flame

Setup instructions:
  - install flutter by following instructions in 
    https://flutter.dev/docs/get-started/install/macos   
  - run flutter doctor
  - run `flutter pub get` to install dependencies
  - open iPhone simulator
  - run `tool/flutter_run_offline.sh -d chrome`

## Docker Pi integration

This repo can run as two side-by-side Docker services:

- `flutter`: runs the Flutter web dev server on http://localhost:8080
- `pi`: runs a small HTTP bridge on http://localhost:8787 that forwards prompts to `pi --mode rpc`

Both services mount this repository at `/workspace/pixelgridOS`, so prompts submitted from the app's Settings > Pi tab can ask Pi to edit the same project files the Flutter service is running.

Start everything:

```bash
docker compose up --build
```

Then open http://localhost:8080, go to Settings > Pi, type a prompt, and submit it.

Optional Pi configuration can be passed through environment variables, for example:

```bash
ANTHROPIC_API_KEY=... PI_PROVIDER=anthropic PI_MODEL=claude-sonnet-4-5 docker compose up --build
```

Useful endpoints:

- `GET http://localhost:8787/health`
- `GET http://localhost:8787/state`
- `POST http://localhost:8787/prompt` with JSON `{ "message": "..." }`
