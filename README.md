# Passgrinder Desktop

Passgrinder desktop app with matching Chrome-extension styling. Builds are produced for macOS (Universal), Windows, and Linux via GitHub Actions.

## Downloads

Latest release: https://github.com/jeremycaris/passgrinder-desktop/releases/latest

One-click direct downloads:
	- macOS Menu Bar (Universal): https://github.com/jeremycaris/passgrinder-desktop/releases/latest/download/Passgrinder-macOS.dmg
	- Windows (x64): https://github.com/jeremycaris/passgrinder-desktop/releases/latest/download/Passgrinder-Windows.zip
	- Linux (x64): https://github.com/jeremycaris/passgrinder-desktop/releases/latest/download/Passgrinder-Linux.tar.gz


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