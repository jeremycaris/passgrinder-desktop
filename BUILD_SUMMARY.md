# Build Summary

## ⚠️ Important: Cross-Platform Limitations

**You cannot build Windows or Linux apps on macOS.** Flutter requires the native platform to build:

- ✅ macOS builds work on macOS (your current platform)
- ❌ Linux builds require a Linux machine
- ❌ Windows builds require a Windows machine

## ✅ Solution: GitHub Actions (Recommended)

This project includes a GitHub Actions workflow that automatically builds for **all platforms** in the cloud:

1. **Push to GitHub**: Your code is already set up with `.github/workflows/build.yml`
2. **Automatic builds**: GitHub Actions will build on macOS, Linux, and Windows runners
3. **Download artifacts**: Get all platform builds from the Actions tab

### How to Use GitHub Actions

```bash
# Commit and push (if you haven't already)
git add .
git commit -m "Ready for multi-platform builds"
git push origin main
```

Then go to: `https://github.com/YOUR_USERNAME/passgrinder-desktop/actions`

Click on the latest workflow run and download the artifacts:
- `Passgrinder-macOS.dmg`
- `Passgrinder-Linux.tar.gz`
- `Passgrinder-Windows.zip`

## 🎯 Build Commands (Platform-Specific)

### macOS (Current Platform) ✅
```bash
flutter build macos --release
```
**Output:** `build/macos/Build/Products/Release/Passgrinder.app`
**Size:** ~43MB
**Architectures:** x86_64, arm64 (Universal Binary)

#### macOS Menu Bar Usage
- Left-click the menu bar icon to show/hide the window
- Right-click the icon for the app menu (Quit)
- Development run: `flutter run -d macos`

### Linux
```bash
flutter build linux --release
```
**Output:** `build/linux/x64/release/bundle/`
**Note:** Must be built on Linux or using a Linux container/VM

### Windows
```bash
flutter build windows --release
```
**Output:** `build/windows/x64/runner/Release/`
**Note:** Must be built on Windows or using a Windows container/VM

## 🚀 Quick Start

### Build All (on macOS)
```bash
./build_all.sh
```

This script will:
1. Clean previous builds
2. Build macOS universal binary (works on both Intel and Apple Silicon Macs)
3. Build Linux (if on Linux or skip with warning)
4. Build Windows (if on Windows or skip with warning)
5. For macOS, the app appears in the menu bar

## 📦 Distribution Packages

### macOS
- Direct distribution: Share the `.app` bundle
- DMG installer: Use `hdiutil` to create a DMG
- For App Store: Requires code signing and notarization

### Linux
- Tarball: `tar -czf passgrinder-linux.tar.gz bundle/*`
- AppImage: Use `appimage-builder`
- Snap/Flatpak: Follow respective packaging guides

### Windows
- ZIP archive: Compress the Release folder
- Installer: Use Inno Setup or WiX Toolset
- Microsoft Store: Requires packaging as MSIX

## 🔧 Development vs Release Builds

### Development (Debug)
```bash
flutter run -d macos    # or linux/windows
```

### Release (Optimized)
```bash
flutter build macos --release
```

Release builds are:
- Smaller in size
- Faster performance
- No debugging symbols
- Optimized for distribution

## 📋 Next Steps

1. **macOS builds** are ready to distribute now (universal binary works on all modern Macs)
2. **Linux builds** need to be created on a Linux machine or CI/CD
3. **Windows builds** need to be created on a Windows machine or CI/CD

For automated multi-platform builds, consider setting up GitHub Actions or similar CI/CD pipeline.

See [BUILD.md](BUILD.md) for detailed build instructions and troubleshooting.
