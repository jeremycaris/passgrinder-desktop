# Passgrinder Desktop

[![Build Multi-Platform](https://github.com/jeremycaris/passgrinder-desktop/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/jeremycaris/passgrinder-desktop/actions/workflows/build.yml)

Passgrinder desktop app with matching Chrome-extension styling. Builds are produced for macOS (Universal), Windows, and Linux via GitHub Actions.

## Downloads

- Latest builds (auto-published): https://github.com/jeremycaris/passgrinder-desktop/releases/latest
- One-click direct downloads (always non-prerelease):
	- macOS (Universal): https://github.com/jeremycaris/passgrinder-desktop/releases/latest/download/Passgrinder-macOS.dmg
	- Windows (x64): https://github.com/jeremycaris/passgrinder-desktop/releases/latest/download/Passgrinder-Windows.zip
	- Linux (x64): https://github.com/jeremycaris/passgrinder-desktop/releases/latest/download/Passgrinder-Linux.tar.gz
- Every push to `main` publishes a release with these three assets
- Tagging `v*` creates a versioned release (also non-prerelease)

## Features

- macOS menu bar app: left-click toggles window visibility
- Right-click menu with Quit option (clears after close)
- Chromeless window (no title bar/system buttons)
- PNG status icon aligned using system square length
- Consistent UI matching the Chrome extension

## macOS Menu Bar Usage

- Left-click the menu bar icon to show/hide the Passgrinder window
- Right-click the icon to open the app menu and choose Quit
- The window appears below the menu bar near the icon
- After closing the menu, left-click behavior is restored automatically

## Running Locally (macOS)

```bash
flutter run -d macos
```

Notes:
- No `window_manager` plugin is required; native AppKit is used
- Menu lifecycle is handled via `NSMenuDelegate` to prevent sticky menus

## Building (macOS)

```bash
flutter build macos --release
open build/macos/Build/Products/Release/Passgrinder.app
```

For cross-platform builds and artifacts, see [BUILD.md](BUILD.md) and [BUILD_SUMMARY.md](BUILD_SUMMARY.md).