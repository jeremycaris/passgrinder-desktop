#!/bin/bash
# Build script that syncs version from pubspec.yaml before building

set -e

echo "🔄 Syncing version from pubspec.yaml..."
dart scripts/sync_version.dart

if [ "$1" == "macos" ]; then
  echo "🔨 Building for macOS..."
  flutter build macos --release
elif [ "$1" == "windows" ]; then
  echo "🔨 Building for Windows..."
  flutter build windows --release
elif [ "$1" == "linux" ]; then
  echo "🔨 Building for Linux..."
  flutter build linux --release
elif [ "$1" == "all" ]; then
  echo "🔨 Building for all platforms..."
  flutter build macos --release
  flutter build windows --release
  flutter build linux --release
else
  echo "Usage: ./build_with_version.sh [macos|windows|linux|all]"
  echo "Example: ./build_with_version.sh macos"
  exit 1
fi

echo "✅ Build complete"
