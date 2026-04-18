# Furlan Go - Android Build Instructions

## Micro Area 1.7 — Prima Build di Test

### Current Status
- ✅ Scene test prepared (map_scene.tscn)
- ✅ VS Code configured for Godot
- ✅ Android export configured in project.godot
- ✅ Firebase integration configured
- ✅ Build script created (build_android.sh)
- ⏳ Android export templates (pending - disk space required)

### Prerequisites

#### 1. Android Export Templates
**Issue:** Disk is currently full (100% usage). Templates require ~1GB space.

**Solution:** Free up disk space, then install templates:

```bash
# Option A: Install via Godot Editor
godot-4 --editor
# Then: Editor > Manage Export Templates > Download and Install > Android

# Option B: Manual download
# Download from: https://godotengine.org/download/extra/export-templates
# File: Godot_v4.6.1-stable_mono_export_templates.tpz
# Copy to: ~/.local/share/godot/templates/
# Extract: unzip Godot_v4.6.1-stable_mono_export_templates.tpz
```

#### 2. Android SDK (if not already installed)
```bash
sudo apt-get install android-sdk
```

### Build Process

Once templates are installed, run the build script:

```bash
cd /home/daniele/CascadeProjects/furlan-go
./build_android.sh
```

Or manually:

```bash
godot-4 --headless --export-release "Android" build/android/furlan-go-test.apk
```

### Verification

After successful build:
1. APK will be located at: `build/android/furlan-go-test.apk`
2. Install on Android device:
   ```bash
   adb install build/android/furlan-go-test.apk
   ```
3. Launch app and verify:
   - App opens without crashes
   - Map scene loads
   - Firebase connection works (check logs)

### Troubleshooting

**Export templates not found:**
- Ensure templates are installed in `~/.local/share/godot/templates/`
- Check that templates match Godot version (4.6.1)

**Build fails with errors:**
- Check project.godot Android configuration
- Verify all scene files are present
- Check Firebase configuration files are in place

**Firebase connection issues:**
- Verify google-services.json is in android/res/
- Check Firebase project is properly configured
- Review backend logs for connection status

### Configuration Files

- **project.godot** - Main project configuration with Android export settings
- **android/google-services.json** - Firebase configuration (not versioned)
- **android/build.gradle** - Android build configuration with Firebase
- **android/app/build.gradle** - App-level build configuration
- **android/AndroidManifest.xml** - Android manifest with permissions

### Next Steps

Once disk space is available:
1. Install Android export templates
2. Run build script
3. Test APK on device
4. Verify Firebase connection
5. Test basic functionality

### Disk Cleanup Commands

```bash
# Check disk usage
df -h

# Clean package cache
sudo apt-get clean
sudo apt-get autoremove

# Clean old kernels
sudo apt-get autoremove --purge

# Clean user cache
rm -rf ~/.cache/*
rm -rf ~/.local/share/godot/templates/*
```
