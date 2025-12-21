# Passgrinder Desktop

Passgrinder desktop app with matching Chrome-extension styling. Builds are produced for macOS (Universal), Windows, and Linux via GitHub Actions.

## Downloads

- Latest builds (auto-published): https://github.com/jeremycaris/passgrinder-desktop/releases/latest
- One-click direct downloads (always non-prerelease):
	- macOS (Universal): https://github.com/jeremycaris/passgrinder-desktop/releases/latest/download/Passgrinder-macOS.dmg
	- Windows (x64): https://github.com/jeremycaris/passgrinder-desktop/releases/latest/download/Passgrinder-Windows.zip
	- Linux (x64): https://github.com/jeremycaris/passgrinder-desktop/releases/latest/download/Passgrinder-Linux.tar.gz
- Tagging `v*` creates a versioned release (recommended)
- You can also trigger a manual build via the Actions tab (see below)

## Release Builds

- Option B — Tag a version: push a tag like `v1.2.3` to build and publish a versioned release.
	- Commands:
		```bash
		git tag v1.2.3
		git push origin v1.2.3
		```
- Option C — Manual dispatch: run the “Build Multi-Platform” workflow from GitHub → Actions.
	- The workflow will build macOS/Windows/Linux and publish a release with artifacts.
	- A `build-<run_number>` tag is created automatically for manual runs.	- Toggle individual platforms: when running manually, you can select which platforms to build (macOS only, Linux only, Windows only, or any combination).
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

For cross-platform builds and artifacts, see [AGENTS.md](AGENTS.md).