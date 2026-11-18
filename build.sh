#!/bin/bash
# Builds "dist/Touch Type Trainer.app" from web/index.html and mac/.
# Needs the Xcode Command Line Tools (xcode-select --install).
set -euo pipefail
cd "$(dirname "$0")"
APP="dist/Touch Type Trainer.app"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp mac/Info.plist "$APP/Contents/Info.plist"
cp web/index.html "$APP/Contents/Resources/index.html"

echo "› compiling"
swiftc -swift-version 5 -O -target "$(uname -m)-apple-macosx12.0" mac/main.swift -o "$APP/Contents/MacOS/TouchTypeTrainer"

echo "› drawing icon"
swiftc -swift-version 5 mac/make-icon.swift -o "$TMP/make-icon"
"$TMP/make-icon" "$TMP/icon1024.png"
mkdir "$TMP/AppIcon.iconset"
for s in 16 32 128 256 512; do
  sips -z $s $s "$TMP/icon1024.png" --out "$TMP/AppIcon.iconset/icon_${s}x${s}.png" >/dev/null
  sips -z $((s*2)) $((s*2)) "$TMP/icon1024.png" --out "$TMP/AppIcon.iconset/icon_${s}x${s}@2x.png" >/dev/null
done
iconutil -c icns "$TMP/AppIcon.iconset" -o "$APP/Contents/Resources/AppIcon.icns"

echo "› signing (ad hoc)"
codesign --force --deep -s - "$APP"

echo "› done: $APP"
echo "  install with: cp -R \"$APP\" /Applications/"
