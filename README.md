# Passgrinder Desktop

Passgrinder desktop app with matching Chrome-extension styling. Builds are produced for macOS (Universal), Windows, and Linux via GitHub Actions.

## Downloads

- Latest release: https://github.com/jeremycaris/passgrinder-desktop/releases/latest

- One-click direct downloads:
	- macOS Menu Bar (Universal): https://github.com/jeremycaris/passgrinder-desktop/releases/latest/download/Passgrinder-macOS.dmg
	- Windows (x64): https://github.com/jeremycaris/passgrinder-desktop/releases/latest/download/Passgrinder-Windows.zip
	- Linux (x64): https://github.com/jeremycaris/passgrinder-desktop/releases/latest/download/Passgrinder-Linux.tar.gz

## macOS Installation Instructions

Passgrinder is distributed outside the Mac App Store. First, drag the app from the dmg to your Applications folder. Then click on the copy of the app in your applications folder. On first launch, macOS may block it with a warning like:

"Passgrinder.app can't be opened because Apple cannot check it for malicious software."

To allow it:
- Open System Settings → Privacy & Security.
- In the Security section, look for the message that Passgrinder was blocked and click "Open Anyway".
- Confirm by clicking "Open" when prompted.

Alternative (Finder):
- Move the app to the Applications first (approval persists per app path).
- Control‑click the app (Passgrinder.app) → Open → confirm "Open". This approves the app and avoids future prompts.

## Features

- **Single-screen password generator**: Chrome extension-style interface for quick password generation
- **Menu bar integration** (macOS): Convenient access from the status bar
- **Keyboard navigation**: Full keyboard support with intuitive tab order
  - Tab through: Master Password → Unique Phrase → Radio Group → Copy button
  - Arrow keys (←/→/↑/↓) cycle through password variations while focused on radio group
- **Visual feedback**: Focus indicators show which element is selected for keyboard input
- **Dark/light mode support**: Automatically adapts to system theme
- **Auto-reset timer**: Clears sensitive data after 1 minute of inactivity
- **Cross-platform**: Available for macOS, Windows, and Linux

# Build Instructions
```bash
flutter run -d macos
```

# Release Instructions
Option 1:
- Run manual action in github
- Rename the release it generates

Option 2:
Create the tag locally
```bash
git tag 1.0.2
```
Push the tag (this triggers the workflow)
```bash
git push origin 1.0.2
```