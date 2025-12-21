#!/bin/bash

# Build script for Passgrinder Desktop
# Note: This can only build for the current platform
# For multi-platform builds, use GitHub Actions

set -e

echo "🚀 Building Passgrinder for current platform..."
echo ""

# Detect platform
if [[ "$OSTYPE" == "darwin"* ]]; then
  PLATFORM="macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  PLATFORM="Linux"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
  PLATFORM="Windows"
else
  echo "❌ Unknown platform: $OSTYPE"
  exit 1
fi

echo "📍 Detected platform: $PLATFORM"
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get
echo ""

# Build for current platform
if [[ "$PLATFORM" == "macOS" ]]; then
  echo "🍎 Building macOS Universal Binary (ARM64 + x86_64)..."
  flutter build macos --release
  echo "✅ macOS build complete: build/macos/Build/Products/Release/Passgrinder.app"
  echo ""
  echo "Creating DMG..."
  hdiutil create -volname Passgrinder \
    -srcfolder build/macos/Build/Products/Release/Passgrinder.app \
    -ov -format UDZO Passgrinder-macOS.dmg
  echo "✅ DMG created: Passgrinder-macOS.dmg"
  
elif [[ "$PLATFORM" == "Linux" ]]; then
  echo "🐧 Building Linux..."
  flutter build linux --release
  echo "✅ Linux build complete: build/linux/x64/release/bundle/"
  echo ""
  echo "Creating tarball..."
  cd build/linux/x64/release/bundle
  tar -czf ../../../../../Passgrinder-Linux.tar.gz *
  cd ../../../../../
  echo "✅ Tarball created: Passgrinder-Linux.tar.gz"
  
elif [[ "$PLATFORM" == "Windows" ]]; then
  echo "🪟 Building Windows..."
  flutter build windows --release
  echo "✅ Windows build complete: build/windows/x64/runner/Release/"
  echo ""
  echo "Creating ZIP..."
  powershell Compress-Archive -Path build/windows/x64/runner/Release/* -DestinationPath Passgrinder-Windows.zip
  echo "✅ ZIP created: Passgrinder-Windows.zip"
fi

echo ""
echo "✨ Build complete!"
echo ""
echo "⚠️  Note: To build for other platforms, use GitHub Actions"
echo "   Push to GitHub and builds will run automatically for all platforms"

