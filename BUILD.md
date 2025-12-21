# Passgrinder Desktop - Build Guide

## Building for Multiple Platforms

This project supports macOS (ARM + Intel), Linux, and Windows.

### Prerequisites

- Flutter SDK (latest stable)
- Platform-specific build tools:
  - **macOS**: Xcode Command Line Tools
  - **Linux**: CMake, GTK development headers
  - **Windows**: Visual Studio 2022 with C++ Desktop Development

### Quick Build (macOS/Linux)

Run the provided build script:

```bash
./build_all.sh
```

This will build for macOS and Linux. Windows builds must be done on Windows.

### Platform-Specific Builds

#### macOS (Universal Binary - ARM + Intel)

```bash
flutter build macos --release
```

Output: `build/macos/Build/Products/Release/Passgrinder.app`

To create separate ARM and Intel builds:
```bash
# ARM only (M1/M2/M3)
flutter build macos --release --dart-define=FLUTTER_BUILD_MODE=release

# Intel only
flutter build macos --release --target-platform macos-x64
```

#### Linux

```bash
flutter build linux --release
```

Output: `build/linux/x64/release/bundle/`

To create a distributable package:
```bash
# Install AppImage tools (if not already installed)
sudo apt-get install appimage-builder

# Or create a tarball
cd build/linux/x64/release/bundle
tar -czf passgrinder-linux.tar.gz *
```

#### Windows

Must be run on Windows:

```powershell
flutter build windows --release
```

Output: `build\windows\x64\runner\Release\`

### Distribution

#### macOS
- The `.app` bundle is ready to distribute
- For signing and notarization, see [Apple Developer Documentation](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- To create a DMG:
  ```bash
  hdiutil create -volname Passgrinder -srcfolder build/macos/Build/Products/Release/Passgrinder.app -ov -format UDZO Passgrinder.dmg
  ```

#### Linux
- The `bundle/` directory contains all necessary files
- Create a tarball or AppImage for distribution
- Or use `flutter_distributor` package for automated packaging

#### Windows
- The `Release/` folder contains the executable and dependencies
- Use Inno Setup or WiX to create an installer
- Or distribute as a ZIP archive

### CI/CD

For automated builds across all platforms, consider using:
- GitHub Actions
- GitLab CI
- Codemagic

Example GitHub Actions workflow coming soon.

### Troubleshooting

**macOS Build Issues:**
- Ensure Xcode is up to date: `xcode-select --install`
- Clean build: `flutter clean && flutter pub get`

**Linux Build Issues:**
- Install GTK3 dev libraries: `sudo apt-get install libgtk-3-dev`
- Install other deps: `sudo apt-get install clang cmake ninja-build pkg-config`

**Windows Build Issues:**
- Ensure Visual Studio 2022 with C++ Desktop Development is installed
- Run from Developer Command Prompt for VS 2022
