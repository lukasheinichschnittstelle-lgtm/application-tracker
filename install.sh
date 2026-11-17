#!/bin/bash
# Installs or updates Application Tracker in ~/Applications.
# Your data is never touched: ~/Library/Application Support/Application Tracker/
set -euo pipefail
APP_NAME="Application Tracker"
URL="https://github.com/lukasheinichschnittstelle-lgtm/application-tracker/releases/latest/download/ApplicationTracker.zip"
DEST="$HOME/Applications"

[ "$(uname -s)" = Darwin ] || { echo "Application Tracker runs on macOS only."; exit 1; }
[ "$(uname -m)" = arm64 ] || { echo "Application Tracker needs a Mac with Apple Silicon."; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
echo "Downloading $APP_NAME …"
curl -fsSL "$URL" -o "$TMP/app.zip"
ditto -x -k "$TMP/app.zip" "$TMP"
[ -d "$TMP/$APP_NAME.app" ] || { echo "The download looks broken. Nothing was changed."; exit 1; }

# Quit a running copy first. Every change is saved the moment it is made, so nothing is lost.
if pgrep -x ApplicationTracker >/dev/null; then
  osascript -e "quit app \"$APP_NAME\"" >/dev/null 2>&1 || true
  for _ in 1 2 3 4 5 6 7 8 9 10; do pgrep -x ApplicationTracker >/dev/null || break; sleep 1; done
fi

mkdir -p "$DEST"
rm -rf "${DEST:?}/$APP_NAME.app"
mv "$TMP/$APP_NAME.app" "$DEST/"
open "$DEST/$APP_NAME.app"
echo "Done. $APP_NAME is in $DEST. Run the same command again to update."
