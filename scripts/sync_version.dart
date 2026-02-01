#!/usr/bin/env dart
/// Syncs the version from pubspec.yaml to all platform-specific build configs.
/// Run this before building: dart scripts/sync_version.dart

import 'dart:io';
import 'package:yaml/yaml.dart';

void main() async {
  try {
    // Read pubspec.yaml
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      stderr.writeln('Error: pubspec.yaml not found');
      exit(1);
    }

    final pubspecContent = pubspecFile.readAsStringSync();
    final pubspec = loadYaml(pubspecContent) as Map;
    final version = pubspec['version'] as String;

    if (version.isEmpty) {
      stderr.writeln('Error: version field not found in pubspec.yaml');
      exit(1);
    }

    // Parse version and build number (format: 1.0.1 or 1.0.1+1)
    final versionParts = version.split('+');
    final versionNumber = versionParts[0];
    final buildNumber = versionParts.length > 1 ? versionParts[1] : '1';

    print('📦 Syncing version: $versionNumber (build: $buildNumber)');

    // Update macOS AppInfo.xcconfig
    _updateMacOS(versionNumber, buildNumber);

    // Update macOS Flutter ephemeral configs if present
    _updateMacOSEphemeral(versionNumber, buildNumber);

    // Update Windows CMakeLists.txt
    _updateWindows(versionNumber, buildNumber);

    // Update Linux CMakeLists.txt
    _updateLinux(versionNumber, buildNumber);

    print('✅ Version synced to all platforms');
  } catch (e) {
    stderr.writeln('Error: $e');
    exit(1);
  }
}

void _updateMacOS(String version, String buildNumber) {
  final configFile = File('macos/Runner/Configs/AppInfo.xcconfig');
  if (!configFile.existsSync()) {
    print('⚠️  macOS AppInfo.xcconfig not found');
    return;
  }

  var content = configFile.readAsStringSync();
  
  // Update or add FLUTTER_BUILD_NAME
  if (content.contains('FLUTTER_BUILD_NAME')) {
    content = content.replaceAll(
      RegExp(r'FLUTTER_BUILD_NAME = .*'),
      'FLUTTER_BUILD_NAME = $version',
    );
  } else {
    content = content.replaceAll(
      RegExp(r'(PRODUCT_COPYRIGHT = .*)'),
      '\$1\n\n// The application\'s version\nFLUTTER_BUILD_NAME = $version',
    );
  }

  // Update or add FLUTTER_BUILD_NUMBER
  if (content.contains('FLUTTER_BUILD_NUMBER')) {
    content = content.replaceAll(
      RegExp(r'FLUTTER_BUILD_NUMBER = .*'),
      'FLUTTER_BUILD_NUMBER = $buildNumber',
    );
  } else {
    content = content.replaceAll(
      RegExp(r'(FLUTTER_BUILD_NAME = .*)'),
      '\$1\nFLUTTER_BUILD_NUMBER = $buildNumber',
    );
  }

  configFile.writeAsStringSync(content);
  print('  ✓ macOS version updated');
}

void _updateMacOSEphemeral(String version, String buildNumber) {
  final generatedConfig = File('macos/Flutter/ephemeral/Flutter-Generated.xcconfig');
  if (generatedConfig.existsSync()) {
    var content = generatedConfig.readAsStringSync();
    content = content.replaceAll(
      RegExp(r'^FLUTTER_BUILD_NAME=.*$', multiLine: true),
      'FLUTTER_BUILD_NAME=$version',
    );
    content = content.replaceAll(
      RegExp(r'^FLUTTER_BUILD_NUMBER=.*$', multiLine: true),
      'FLUTTER_BUILD_NUMBER=$buildNumber',
    );
    generatedConfig.writeAsStringSync(content);
    print('  ✓ macOS Flutter-Generated.xcconfig updated');
  }

  final exportEnv = File('macos/Flutter/ephemeral/flutter_export_environment.sh');
  if (exportEnv.existsSync()) {
    var content = exportEnv.readAsStringSync();
    content = content.replaceAll(
      RegExp(r'^export "FLUTTER_BUILD_NAME=.*"$', multiLine: true),
      'export "FLUTTER_BUILD_NAME=$version"',
    );
    content = content.replaceAll(
      RegExp(r'^export "FLUTTER_BUILD_NUMBER=.*"$', multiLine: true),
      'export "FLUTTER_BUILD_NUMBER=$buildNumber"',
    );
    exportEnv.writeAsStringSync(content);
    print('  ✓ macOS flutter_export_environment.sh updated');
  }
}

void _updateWindows(String version, String buildNumber) {
  final cmakeFile = File('windows/runner/CMakeLists.txt');
  if (!cmakeFile.existsSync()) {
    print('⚠️  Windows CMakeLists.txt not found');
    return;
  }

  var content = cmakeFile.readAsStringSync();

  // Check if version is already set in CMakeLists.txt
  if (!content.contains('APP_VERSION')) {
    print('  ℹ️  Windows version management not configured in CMakeLists.txt');
    return;
  }

  content = content.replaceAll(
    RegExp(r'set\(APP_VERSION ".*?"\)'),
    'set(APP_VERSION "$version")',
  );

  cmakeFile.writeAsStringSync(content);
  print('  ✓ Windows version updated');
}

void _updateLinux(String version, String buildNumber) {
  final cmakeFile = File('linux/CMakeLists.txt');
  if (!cmakeFile.existsSync()) {
    print('⚠️  Linux CMakeLists.txt not found');
    return;
  }

  var content = cmakeFile.readAsStringSync();

  // Check if version is already set in CMakeLists.txt
  if (!content.contains('APP_VERSION')) {
    print('  ℹ️  Linux version management not configured in CMakeLists.txt');
    return;
  }

  content = content.replaceAll(
    RegExp(r'set\(APP_VERSION ".*?"\)'),
    'set(APP_VERSION "$version")',
  );

  cmakeFile.writeAsStringSync(content);
  print('  ✓ Linux version updated');
}
