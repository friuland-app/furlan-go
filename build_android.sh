#!/bin/bash

# Furlan Go - Android Build Script
# Micro Area 1.7 — Prima Build di Test

PROJECT_DIR="/home/daniele/CascadeProjects/furlan-go"
OUTPUT_DIR="$PROJECT_DIR/build/android"
APK_NAME="furlan-go-test.apk"

echo "=== Furlan Go Android Build ==="
echo "Project: $PROJECT_DIR"
echo "Output: $OUTPUT_DIR/$APK_NAME"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Check if Godot is installed
if ! command -v godot-4 &> /dev/null; then
    echo "Error: Godot 4 not found"
    exit 1
fi

# Check if export templates are installed
if [ ! -d "$HOME/.local/share/godot/templates" ]; then
    echo "Error: Export templates not found"
    echo "Install templates with: godot-4 --editor"
    echo "Then go to: Editor > Manage Export Templates"
    exit 1
fi

# Export Android APK
echo "Building Android APK..."
godot-4 --headless --export-release "Android" "$OUTPUT_DIR/$APK_NAME"

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "APK location: $OUTPUT_DIR/$APK_NAME"
    ls -lh "$OUTPUT_DIR/$APK_NAME"
else
    echo "❌ Build failed"
    exit 1
fi

echo "=== Build Complete ==="
