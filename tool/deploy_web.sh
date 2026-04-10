#!/usr/bin/env bash
set -euo pipefail

target_branch="${1:-rogue-choices/prod}"
allowed_branches=("rogue-choices/prod" "rogue-choices/staging")
is_allowed=false

for allowed in "${allowed_branches[@]}"; do
  if [[ "$target_branch" == "$allowed" ]]; then
    is_allowed=true
    break
  fi
done

if [[ "$is_allowed" != true ]]; then
  echo "Unsupported deploy branch: $target_branch" >&2
  exit 1
fi

if [[ ! -d .git ]]; then
  echo "Deploy script must run from the repo root." >&2
  exit 1
fi

git checkout "$target_branch"
git reset --hard
git clean -fd
git pull --ff-only origin "$target_branch"

current_branch="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$current_branch" != "$target_branch" ]]; then
  echo "Deployment failed: expected $target_branch, got $current_branch." >&2
  exit 1
fi

flutter build web --release

if [[ ! -d build/web ]]; then
  echo "Deployment failed: build/web missing." >&2
  exit 1
fi

if [[ ! -d ../www ]]; then
  echo "Deployment failed: ../www missing." >&2
  exit 1
fi

rsync -av --delete build/web/ ../www/
