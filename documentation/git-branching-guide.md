# Git Workflow & Branching Guide
Rogue Choices Project

This document explains how we work with Git and GitHub in this repository.
It is required reading for any developer (human or AI) joining the project.

The goals of this workflow are:
- Keep production safe
- Make deployments predictable
- Allow fast iteration with minimal confusion
- Ensure deploys trigger automatically from specific branches

--------------------------------------------------
BRANCH STRUCTURE
--------------------------------------------------

We use four long-lived branches.

main
- Historical reference branch
- Represents released snapshots or tagged versions
- No direct development happens here

rogue-choices/prod
- Production branch
- ALWAYS triggers a production deploy
- Only receives changes from staging via pull request

rogue-choices/staging
- Pre-production / QA branch
- ALWAYS triggers a staging deploy
- Default branch for pull requests
- Where features are validated together

rogue-choices/dev
- Active development and AI-assisted work branch
- ALWAYS triggers a dev deploy
- Used for early integration and experimentation

Feature branches
- Short-lived
- Created from dev or staging
- Deleted automatically after merge

--------------------------------------------------
DEPLOYMENT RULE
--------------------------------------------------

Any push or merge to the following branches triggers a deploy automatically:

- rogue-choices/dev
- rogue-choices/staging
- rogue-choices/prod

No exceptions.

--------------------------------------------------
SCENARIO 1: USING GITHUB WEB UI (NO TERMINAL)
--------------------------------------------------

Creating a new branch in GitHub:

1) Go to the repository on GitHub
2) Click the branch selector (top left)
3) Select the base branch:
   - dev for new features
   - staging for fixes
4) Type the new branch name
   Example:
   rogue-choices/feature-menu-polish
5) Click "Create branch"

Making changes and opening a Pull Request:

1) Edit files directly in GitHub OR push commits from elsewhere
2) Go to the "Pull requests" tab
3) Click "New pull request"
4) Set base branch:
   - dev, staging, or prod (depending on intent)
5) Set compare branch:
   - your feature branch
6) Create the pull request
7) Merge when checks pass

After merge:
- The feature branch is deleted automatically
- A deploy is triggered if base branch is dev, staging, or prod

--------------------------------------------------
SCENARIO 2: USING TERMINAL (RAW GIT)
--------------------------------------------------

Initial setup (run once):

1) Clone the repository
   git clone <repo-url>
   cd <repo-name>

2) Fetch all branches
   git fetch --all

--------------------------------------------------
CREATING A NEW FEATURE BRANCH
--------------------------------------------------

1) Switch to the correct base branch
   git checkout rogue-choices/dev
   git pull

2) Create a new branch
   git checkout -b rogue-choices/feature-your-feature-name

3) Push and set upstream
   git push -u origin rogue-choices/feature-your-feature-name

--------------------------------------------------
WORKING AND PUSHING CHANGES
--------------------------------------------------

1) Make code changes
2) Check status
   git status

3) Stage changes
   git add .

4) Commit
   git commit -m "Describe the change clearly"

5) Push
   git push

--------------------------------------------------
OPENING A PULL REQUEST (TERMINAL FLOW)
--------------------------------------------------

1) Push your branch (if not already pushed)
2) Go to GitHub
3) Open a Pull Request:
   - Base: rogue-choices/dev OR rogue-choices/staging
   - Compare: your feature branch
4) Merge via GitHub UI

--------------------------------------------------
PROMOTING BETWEEN ENVIRONMENTS
--------------------------------------------------

Dev → Staging:

1) Create a PR
   base: rogue-choices/staging
   compare: rogue-choices/dev
2) Merge
3) Staging deploy triggers automatically

Staging → Prod:

1) Create a PR
   base: rogue-choices/prod
   compare: rogue-choices/staging
2) Merge
3) Production deploy triggers automatically

--------------------------------------------------
CLEANING UP LOCAL BRANCHES
--------------------------------------------------

Remove branches that were deleted on GitHub:

1) Prune remote refs
   git fetch --prune

2) Delete local branches whose remote is gone
   git branch -vv | awk '/: gone]/{print $1}' | xargs git branch -d

This does NOT delete:
- Local-only branches
- Active branch
- Unmerged work

--------------------------------------------------
NAMING RULES
--------------------------------------------------

Correct:
- rogue-choices/dev
- rogue-choices/staging
- rogue-choices/prod
- rogue-choices/feature-login-flow

Incorrect:
- rogue-choices/rogue-choices/anything
- random-branch-names
- main-feature-x

--------------------------------------------------
SUMMARY
--------------------------------------------------

- dev, staging, and prod always deploy
- PRs default to staging
- Feature branches are short-lived
- GitHub auto-deletes merged branches
- Local cleanup is manual and safe
- This workflow applies equally to humans and AI contributors

If in doubt:
- Do NOT push directly to prod
- Create a PR
- Ask before force-deleting anything