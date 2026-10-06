#!/usr/bin/env bash
set -e

# Universal Cross-Platform Build Script for Diorama Sandbox (Godot 4)
# Supported Targets: Linux x86_64, Windows x86_64, Android ARM64

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

export PATH="/opt/android-sdk/build-tools/37.0.0:/opt/android-sdk/platform-tools:$PATH"
export ANDROID_HOME="/opt/android-sdk"

mkdir -p builds/linux builds/windows builds/android

echo "=========================================================="
echo "🏗️  Starting Diorama Sandbox Cross-Platform Builds"
echo "=========================================================="

# 1. Build Linux x86_64
echo ""
echo "▶ [1/3] Building Linux (x86_64)..."
godot --headless --export-release "Linux / X11" builds/linux/DioramaSandbox.x86_64
chmod +x builds/linux/DioramaSandbox.x86_64
echo "✓ Linux Build Complete: builds/linux/DioramaSandbox.x86_64"

# 2. Build Windows x86_64
echo ""
echo "▶ [2/3] Building Windows Desktop (x86_64)..."
TEMPLATE_DIR="$HOME/.local/share/godot/export_templates/4.7.2.stable"
if [ -f "$TEMPLATE_DIR/windows_release_x86_64.exe" ]; then
    godot --headless --export-release "Windows Desktop" builds/windows/DioramaSandbox.exe
    echo "✓ Windows Executable Complete: builds/windows/DioramaSandbox.exe"
else
    echo "ℹ Windows release template not found in $TEMPLATE_DIR. Exporting PCK package..."
    godot --headless --export-pack "Windows Desktop" builds/windows/DioramaSandbox.pck
    echo "✓ Windows Data Package Complete: builds/windows/DioramaSandbox.pck"
fi

# 3. Build Android ARM64
echo ""
echo "▶ [3/3] Building Android (ARM64)..."
if [ -f "$TEMPLATE_DIR/android_debug.apk" ] || [ -f "$TEMPLATE_DIR/android_release.apk" ]; then
    godot --headless --export-debug "Android" builds/android/DioramaSandbox.apk
    echo "✓ Android APK Complete: builds/android/DioramaSandbox.apk"
else
    echo "ℹ Android export template not found. Exporting Android PCK package..."
    godot --headless --export-pack "Android" builds/android/DioramaSandbox.pck
    echo "✓ Android Data Package Complete: builds/android/DioramaSandbox.pck"
fi

echo ""
echo "=========================================================="
echo "🎉 Cross-Platform Builds Completed Successfully!"
echo "Artefakte:"
ls -lh builds/linux/
ls -lh builds/windows/
ls -lh builds/android/
echo "=========================================================="
