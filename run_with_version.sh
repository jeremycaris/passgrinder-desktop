#!/bin/bash
# Run script that syncs version from pubspec.yaml before launching

set -e

echo "🔄 Syncing version from pubspec.yaml..."
dart scripts/sync_version.dart

echo "▶️  Running on macOS..."
flutter run -d macos
