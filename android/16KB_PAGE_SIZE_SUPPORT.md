# 16KB Page Size Support Configuration

## Overview

This document outlines the changes made to support 16KB memory page sizes as required by Google Play Console for apps targeting Android 15+ (effective November 1, 2025).

## Changes Made

### 1. Updated `android/app/build.gradle`

#### Added NDK Configuration

```gradle
ndk {
    abiFilters 'arm64-v8a', 'armeabi-v7a', 'x86_64'
}
```

#### Updated Packaging Options

```gradle
packagingOptions {
    // Fixes duplicate libraries build issue,
    // when your project uses more than one plugin that depend on C++ libs.
    pickFirst 'lib/**/libc++_shared.so'

    // Support for 16KB page sizes
    jniLibs {
        useLegacyPackaging = false
    }
}
```

#### Updated Core Library Desugaring

```gradle
coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.4'
```

### 2. Updated `android/gradle.properties`

#### Added 16KB Page Size Support Properties

```properties
# Support for 16KB page sizes (required for Android 15+)
android.bundle.enableUncompressedNativeLibs=false
android.enableR8.fullMode=true
```

## Current Configuration Status

✅ **Android Gradle Plugin**: 8.7.3 (supports 16KB page sizes)  
✅ **Compile SDK**: 35 (Android 15)  
✅ **Target SDK**: 35 (Android 15)  
✅ **NDK Configuration**: Added with proper ABI filters  
✅ **Packaging Options**: Updated for 16KB page size support  
✅ **Core Library Desugaring**: Updated to version 2.0.4

## Next Steps

### 1. Test Your App

- Build and test your app to ensure it works correctly
- Test on devices with 16KB page sizes if available
- Use Android Emulator configured for 16KB page sizes for testing

### 2. Flutter Dependencies

Since this is a Flutter project, ensure your Flutter dependencies are up to date:

```bash
flutter pub upgrade
```

### 3. Build and Deploy

```bash
flutter build appbundle --release
```

### 4. Verify Compliance

- Upload your app bundle to Google Play Console
- Check that the Play Console no longer shows the 16KB page size warning
- Monitor for any issues during the review process

## Important Notes

- **Deadline**: November 1, 2025 (with possible extension until May 31, 2026)
- **Impact**: Apps not supporting 16KB page sizes cannot release updates after the deadline
- **Testing**: Use Samsung Remote Test Lab or Android Emulator for 16KB page size testing
- **Native Libraries**: All native libraries must be rebuilt with NDK r28+ for 16KB page size support

## Resources

- [Android Developer Guide: Support 16 KB Page Sizes](https://developer.android.com/guide/practices/page-sizes)
- [Samsung Remote Test Lab for 16KB Testing](https://developer.samsung.com/remote-test-lab/blog/en/2025/07/07/optimize-your-applications-for-16-kb-page-size-compatibility-using-samsungs-remote-test-lab)
