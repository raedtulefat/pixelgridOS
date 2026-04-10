#!/usr/bin/env bash
set -euo pipefail

run_flutter() {
  flutter "$@"
}

have_package_config() {
  [[ -f ".dart_tool/package_config.json" ]]
}

if run_flutter pub get --offline >/dev/null 2>&1; then
  echo "Using cached dependencies (offline)."
  run_flutter run --no-pub "$@"
  exit $?
fi

echo "Offline cache miss; trying network fetch..."
if run_flutter pub get; then
  run_flutter run "$@"
  exit $?
fi

echo "flutter pub get failed." >&2
if have_package_config; then
  echo "Falling back to cached dependencies; connect to the internet next time to refresh." >&2
  run_flutter run --no-pub "$@"
else
  echo "No cached dependencies available; connect to the internet and run the script again." >&2
  exit 1
fi
