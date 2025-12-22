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
- Control‑click the app (Passgrinder.app) → Open → confirm "Open". This approves the app and avoids future prompts.

Tips:
- Move the app to Applications first; approval persists per app path.
- If the "Open Anyway" button doesn’t appear, you can remove the quarantine attribute as a last resort:

```bash
xattr -dr com.apple.quarantine /Applications/Passgrinder.app
```

Use this carefully; the recommended path is via System Settings or Finder "Open".