# Passgrinder Desktop — Agent Guide

This doc consolidates key guidance for working on Passgrinder Desktop across native macOS AppKit and Flutter code.

## Project Overview
- Flutter desktop app with Chrome-extension-style single-screen password generator.
- macOS app is a menu bar (status bar) app implemented with native AppKit.
- UI and state handled in Flutter; status bar and window chrome via Swift.

## macOS Behavior
- Status icon size: uses `NSStatusItem.squareLength` for proper spacing.
- Left-click: toggles the window (show/hide) under the menu bar near the icon.
- Right-click: opens a temporary menu with Quit; menu is cleared in `menuDidClose(_:)` to restore left-click behavior.
- Window: borderless, transparent, floating; fixed to 460x380; hides on click outside via delayed `resignKey`.

## Flutter Structure
- Entry: `lib/main.dart`
- State: `lib/services/generator_service.dart` (`ChangeNotifier`), auto-generates on setter changes.
- Algorithm: `lib/models/password_generator.dart` — MD5(master) + MD5(unique) + MD5(variation) → MD5 → custom Z85 alphabet → 20-char password.
- UI: `lib/screens/home_screen.dart` (inputs, variations, copy+snackbar), `lib/widgets/password_field.dart` (masked mono, copy/show/hide icons).
- Theming: dark palette in `lib/main.dart` (bg #1e2629, green #6baf78); fonts via `pubspec.yaml` (Lato, SourceCodePro).

## Native macOS Files
- Status bar + menu: `macos/Runner/AppDelegate.swift`
- Window chrome: `macos/Runner/MainFlutterWindow.swift`
- Assets: `macos/Runner/Assets.xcassets/AppIcon.appiconset/`

## Build & Run
- Development (macOS):
  ```bash
  flutter run -d macos
  ```
- Release (macOS):
  ```bash
  flutter build macos --release
  open build/macos/Build/Products/Release/Passgrinder.app
  ```

## Releases
- Option B — Tag a version:
  - Create and push a tag matching `v*` to build and publish a versioned release.
  - Example:
    ```bash
    git tag v1.2.3
    git push origin v1.2.3
    ```
- Option C — Manual dispatch:
  - Run the “Build Multi-Platform” workflow from GitHub → Actions.
  - CI builds macOS/Windows/Linux and publishes a release; a `build-<run_number>` tag is created automatically.
- Note: Pushes to `main` no longer auto-publish releases.

## Dependencies & Constraints
- Flutter packages: `provider`, `crypto`, `font_awesome_flutter`.
- Avoid window_manager plugin; macOS status/window handled natively via AppKit.

## Testing
- Default widget test exists in `test/`.
- If modifying password algorithm, add targeted unit tests near `PasswordGenerator`.

## Assets
- Status bar icon and app icons in `assets/icon/` and `macos/Runner/Assets.xcassets/AppIcon.appiconset/`.
- Fonts in `assets/fonts/` (Lato, SourceCodePro) declared in `pubspec.yaml`.
