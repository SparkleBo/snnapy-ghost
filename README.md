# SnnapyGhost

Lightweight floating screenshot tool for the latest macOS on Apple Silicon.

中文说明请看: [README.zh-CN.md](./README.zh-CN.md)

SnnapyGhost runs as a menu bar app. Press `control + shift + 2`, drag to select a region, and the captured image will immediately appear as a floating always-on-top window that you can move around. Double-click the floating image to close it.

## Features

- Menu bar background app with no main window
- Global hotkey: `control + shift + 2`
- Region selection screenshot
- Floating screenshot window after capture
- Draggable floating image
- Always-on-top behavior
- Visible across Spaces and fullscreen apps
- Multiple floating screenshots at the same time
- Double-click to close any floating screenshot

## Requirements

- macOS 15.2 or later
- Apple Silicon / M-series chip
- Screen Recording permission granted
- Swift toolchain installed

Note:
The current version can be built with Command Line Tools. Full Xcode is recommended later if you want a better debugging, signing, or distribution workflow.

## Installation

### Option 1: Build from source

From the project root:

```bash
rtk swift build
rtk bash Scripts/build_app.sh
```

The app bundle will be created at:

```text
dist/SnnapyGhost.app
```

You can launch that `.app` directly, or move it into `/Applications` first.

### Option 2: Run the development build

For a quick local test:

```bash
rtk swift run SnnapyGhost
```

## First Launch

SnnapyGhost is a menu bar app, so it does not show a Dock icon or a normal main window.

After launch, confirm one of the following:

- You can see the camera icon in the menu bar
- Pressing `control + shift + 2` starts selection mode

## Permission Setup

SnnapyGhost requires the macOS Screen Recording permission.

If macOS prompts you on first use, allow the permission.

If the prompt does not appear, open:

```text
System Settings > Privacy & Security > Screen & System Audio Recording
```

Enable `SnnapyGhost` there.

Important:
After granting permission, you usually need to fully quit and relaunch the app before the permission becomes effective for the current process.

## Usage

1. Launch `SnnapyGhost.app`
2. Press `control + shift + 2`
3. Drag to select the screen region you want to capture
4. Release the mouse to create a floating screenshot
5. Drag the floating image anywhere you like
6. Double-click the floating image to close it

## Menu Bar Actions

From the menu bar icon, you can:

- Start a capture manually
- Check permission status
- Request screen recording permission
- Open System Settings
- Quit the app

## Troubleshooting

### The app looks like it did not open

That is expected for a menu bar app. There is no Dock icon or main window. Check the menu bar instead.

### Permission is enabled, but the app still says it is missing

Make sure you are running the latest rebuilt `.app`.

Then follow this order:

1. Quit SnnapyGhost
2. Turn the Screen Recording permission for `SnnapyGhost` off and on again in System Settings
3. Relaunch the app

If it still does not work, reset the permission:

```bash
rtk tccutil reset ScreenCapture local.construct.SnnapyGhost
```

Then open the app again and grant the permission one more time.

### The app crashes after capture

Make sure you are using the latest build. If the issue persists, inspect the newest crash reports in:

```text
~/Library/Logs/DiagnosticReports/
```

## Development

This project uses:

- Swift Package Manager
- AppKit
- Carbon HotKey API
- ScreenCaptureKit

Common commands:

```bash
rtk swift build
rtk swift run SnnapyGhost
rtk bash Scripts/build_app.sh
```
