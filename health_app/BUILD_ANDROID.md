# Android Build and Deployment Guide

## Prerequisites

1. **Flutter SDK**: Install Flutter SDK (version 3.0 or higher)
2. **Android Studio**: Install Android Studio with Android SDK
3. **Java Development Kit (JDK)**: Install JDK 11 or higher
4. **Keystore**: Create a keystore for signing release builds

## Setup Instructions

### 1. Initial Setup

```bash
cd health_app

# Get Flutter dependencies
flutter pub get

# Check Flutter installation
flutter doctor

# Fix any issues reported by flutter doctor
```

### 2. Android Configuration

Create `android/local.properties` from the example:

```bash
cp android/local.properties.example android/local.properties
```

Edit `local.properties` and set your Flutter SDK path:

```properties
flutter.sdk=/path/to/your/flutter/sdk
flutter.buildMode=release
```

### 3. Create Signing Keystore (for release builds)

Generate a keystore for signing your app:

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Create `android/key.properties` (this file is in .gitignore):

```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=upload
storeFile=/home/<username>/upload-keystore.jks
```

Update `android/app/build.gradle` to configure signing:

```gradle
// Add this before the android block
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing code ...

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            // ... existing code ...
        }
    }
}
```

## Build Commands

### Debug Build

```bash
# Build debug APK
flutter build apk --debug

# Install debug APK on connected device
flutter install
```

### Release Build

```bash
# Build release APK
flutter build apk --release

# Build App Bundle for Play Store
flutter build appbundle --release

# Build with specific flavor (if configured)
flutter build apk --release --flavor production
```

### Build Output Locations

- **Debug APK**: `build/app/outputs/flutter-apk/app-debug.apk`
- **Release APK**: `build/app/outputs/flutter-apk/app-release.apk`
- **App Bundle**: `build/app/outputs/bundle/release/app-release.aab`

## Testing

### Run on Connected Device

```bash
# Run in debug mode
flutter run

# Run in release mode
flutter run --release

# Run on specific device
flutter devices
flutter run -d <device-id>
```

### Run Tests

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run with coverage
flutter test --coverage
```

## Deployment

### Google Play Store Deployment

1. **Create Play Store Listing**:
   - Go to [Google Play Console](https://play.google.com/console)
   - Create a new app
   - Fill in store listing information

2. **Upload App Bundle**:
   ```bash
   flutter build appbundle --release
   ```
   - Upload the generated `.aab` file to Play Console

3. **Configure Release**:
   - Set up content ratings
   - Add screenshots and promotional graphics
   - Configure pricing and distribution
   - Submit for review

### Testing Tracks

Use testing tracks before full release:

```bash
# Build for internal testing
flutter build appbundle --release --flavor internal

# Build for closed testing
flutter build appbundle --release --flavor closed
```

## Troubleshooting

### Common Issues

1. **Gradle Build Failed**:
   ```bash
   cd android
   ./gradlew clean
   cd ..
   flutter clean
   flutter pub get
   flutter build apk
   ```

2. **Outdated Dependencies**:
   ```bash
   flutter pub upgrade
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **Keystore Issues**:
   - Verify keystore path in `key.properties`
   - Check keystore password and alias
   - Ensure keystore file exists

4. **Build Version Conflicts**:
   - Check `android/app/build.gradle` for compileSdkVersion
   - Update Gradle and Kotlin versions if needed
   - Run `flutter doctor -v` to diagnose issues

## Performance Optimization

### Reduce APK Size

```bash
# Split APK by ABI
flutter build apk --split-per-abi

# Enable code shrinking (already configured in build.gradle)
flutter build apk --release --obfuscate --split-debug-info=./debug-info
```

### Build Performance

```bash
# Build with specific platform
flutter build apk --release --target-platform android-arm64

# Build with dart2native (faster startup)
flutter build apk --release --dart-define=PRODUCTION=true
```

## Monitoring

### Crash Reporting

Consider integrating:
- Firebase Crashlytics
- Sentry for Flutter
- Custom error reporting

### Analytics

Consider integrating:
- Firebase Analytics
- Google Analytics for Firebase
- Custom analytics solution

## Continuous Integration

### GitHub Actions Example

Create `.github/workflows/android.yml`:

```yaml
name: Build Android APK

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: actions/setup-java@v3
      with:
        java-version: '17'
        distribution: 'temurin'
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.13.0'
    - run: flutter pub get
    - run: flutter test
    - run: flutter build apk --release
    - uses: actions/upload-artifact@v3
      with:
        name: release-apk
        path: build/app/outputs/flutter-apk/app-release.apk
```

## Security Best Practices

1. **Never commit keystore files** - Keep `key.properties` and `.jks` files secure
2. **Use different signing configs** for different environments
3. **Enable code obfuscation** for release builds
4. **Keep dependencies updated** - Run `flutter pub upgrade` regularly
5. **Use environment variables** for sensitive configuration
6. **Enable ProGuard/R8** - Already configured in `build.gradle`

## Support

For issues related to:
- **Flutter**: Visit [Flutter Documentation](https://flutter.dev/docs)
- **Android Development**: Visit [Android Developer Documentation](https://developer.android.com/docs)
- **Google Play Store**: Visit [Google Play Console Help](https://support.google.com/googleplay/android-developer)

---

**Last Updated**: April 22, 2026
**App Version**: 1.0.0
**Build Configuration**: Release