#!/bin/bash

# Build script for Passgrinder Desktop
# Builds for macOS (ARM + Intel), Windows, and Linux

set -e

echo "🚀 Building Passgrinder for all platforms..."
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get
echo ""

# Build macOS Universal Binary (ARM + Intel)
echo "🍎 Building macOS Universal Binary (ARM64 + x86_64)..."
flutter build macos --release
echo "✅ macOS build complete: build/macos/Build/Products/Release/Passgrinder.app"
echo ""

# Build Linux
echo "🐧 Building Linux..."
flutter build linux --release
echo "✅ Linux build complete: build/linux/x64/release/bundle/"
echo ""

# Build Windows (requires Windows or cross-compilation)
echo "🪟 Building Windows..."
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
  flutter build windows --release
  echo "✅ Windows build complete: build/windows/x64/runner/Release/"
else
  echo "⚠️  Windows builds must be created on a Windows machine or via CI/CD"
  echo "   To build on Windows, run: flutter build windows --release"
fi
echo ""

echo "✨ Build process complete!"
echo ""
echo "📦 Outputs:"
echo "  • macOS: build/macos/Build/Products/Release/Passgrinder.app"
echo "  • Linux: build/linux/x64/release/bundle/"
echo "  • Windows: build/windows/x64/runner/Release/ (if on Windows)"
