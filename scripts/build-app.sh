#!/bin/bash
# Builds "Application Tracker.app" (arm64, ad-hoc signed) and build/ApplicationTracker.zip. Runs on macOS (CI).
# Usage: scripts/build-app.sh [version]
set -euo pipefail
VERSION="${1:-0.0.0}"
APP="build/Application Tracker.app"

rm -rf build
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources/Fonts" build/AppIcon.iconset
swift build -c release --arch arm64
cp "$(swift build -c release --arch arm64 --show-bin-path)/ApplicationTracker" "$APP/Contents/MacOS/"
sed "s/0\.0\.0/$VERSION/g" Resources/Info.plist > "$APP/Contents/Info.plist"
cp Resources/Fonts/*.ttf Resources/Fonts/OFL-*.txt "$APP/Contents/Resources/Fonts/"

swift scripts/make-icon.swift Resources/Fonts/Archivo-ExtraBold.ttf build/icon.png
for s in 16 32 128 256 512; do
  sips -z "$s" "$s" build/icon.png --out "build/AppIcon.iconset/icon_${s}x${s}.png" >/dev/null
  sips -z $((s * 2)) $((s * 2)) build/icon.png --out "build/AppIcon.iconset/icon_${s}x${s}@2x.png" >/dev/null
done
iconutil -c icns build/AppIcon.iconset -o "$APP/Contents/Resources/AppIcon.icns"

codesign --force --deep --sign - "$APP"
codesign --verify --deep --strict "$APP"
(cd build && ditto -c -k --keepParent "Application Tracker.app" ApplicationTracker.zip)
echo "Built build/ApplicationTracker.zip ($VERSION)"
