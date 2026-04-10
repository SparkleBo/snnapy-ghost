#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="SnnapyGhost"
BUILD_DIR="$ROOT_DIR/.build/release"
DIST_DIR="$ROOT_DIR/dist"
APP_DIR="$DIST_DIR/$APP_NAME.app"
INFO_PLIST="$ROOT_DIR/Resources/Info.plist"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$INFO_PLIST")"
ZIP_NAME="$APP_NAME-v$VERSION-macos-arm64.zip"
ZIP_PATH="$DIST_DIR/$ZIP_NAME"

swift build -c release

mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"
cp "$INFO_PLIST" "$APP_DIR/Contents/Info.plist"
cp "$BUILD_DIR/$APP_NAME" "$APP_DIR/Contents/MacOS/$APP_NAME"
chmod +x "$APP_DIR/Contents/MacOS/$APP_NAME"
codesign --force --deep --sign - --timestamp=none "$APP_DIR"
rm -f "$ZIP_PATH"
ditto -c -k --sequesterRsrc --keepParent "$APP_DIR" "$ZIP_PATH"

echo "App bundle created at: $APP_DIR"
echo "Release zip created at: $ZIP_PATH"
