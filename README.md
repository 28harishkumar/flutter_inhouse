# Flutter Inhouse SDK

A Flutter plugin for tracking app installs, sessions, and user interactions with shortlinks and deep links using the TryInhouse SDK.

## Features

- **App Install Tracking**: Track app installations and first launches
- **Session Management**: Monitor app sessions and user engagement
- **Deep Link Handling**: Process shortlinks and deep links
- **Install Referrer**: Get Google Play install referrer data (Android)
- **Device Fingerprinting**: Generate unique device fingerprints (Android only)
- **Real-time Callbacks**: Listen to SDK events and responses
- **Cross-platform**: Works on both iOS (16.0+) and Android (API 24+)

## Getting Started

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_inhouse: ^1.0.1
```

Then run:

```bash
flutter pub get
```

### Platform Setup

#### iOS Setup

1. Add the following to your iOS app's `Info.plist`:

```xml
<key>NSUserTrackingUsageDescription</key>
<string>This app needs to track users for analytics purposes.</string>
```

2. The plugin automatically includes the `InhouseTrackingSDK` dependency via CocoaPods.

#### Android Setup

1. The plugin automatically includes the Android SDK dependency.

2. Make sure your app's `minSdk` is at least 24 in `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdk 24
        // ...
    }
}
```

## Usage

### Initialize the SDK

```dart
import 'package:flutter_inhouse/flutter_inhouse.dart';

final FlutterInhouse sdk = FlutterInhouse.instance;

// Initialize the SDK
try {
  final result = await sdk.initialize(
    projectToken: 'your_project_token',
    tokenId: 'your_token_id',
    shortLinkDomain: 'yourdomain.com',
    serverUrl: 'https://api.tryinhouse.co', // Optional
    enableDebugLogging: true, // Optional, default: false
  );
  print('SDK initialized: $result');
} catch (e) {
  print('Failed to initialize SDK: $e');
}
```

### Track Events

#### Track App Open

```dart
try {
  final response = await sdk.trackAppOpen();
  print('App open tracked: $response');
} catch (e) {
  print('Failed to track app open: $e');
}
```

#### Track Session Start

```dart
try {
  final response = await sdk.trackSessionStart();
  print('Session start tracked: $response');
} catch (e) {
  print('Failed to track session start: $e');
}
```

#### Track Short Link Click

```dart
try {
  final response = await sdk.trackShortLinkClick(
    shortLink: 'https://yourdomain.com/abc123',
    deepLink: 'myapp://home', // Optional
  );
  print('Short link click tracked: $response');
} catch (e) {
  print('Failed to track short link click: $e');
}
```

### Install Referrer (Android)

```dart
// Get cached install referrer
try {
  final referrer = await sdk.getInstallReferrer();
  print('Install referrer: $referrer');
} catch (e) {
  print('Failed to get install referrer: $e');
}

// Fetch fresh install referrer
try {
  final referrer = await sdk.fetchInstallReferrer();
  print('Fetched install referrer: $referrer');
} catch (e) {
  print('Failed to fetch install referrer: $e');
}
```

### Device Fingerprinting (Android Only)

```dart
// Get device fingerprint
try {
  final fingerprint = await sdk.getFingerprint();
  if (fingerprint.isNotEmpty) {
    print('Device fingerprint: $fingerprint');
  }
} catch (e) {
  print('Failed to get fingerprint: $e');
}

// Get fingerprint ID
try {
  final fingerprintId = await sdk.getFingerprintId();
  if (fingerprintId.isNotEmpty) {
    print('Fingerprint ID: $fingerprintId');
  }
} catch (e) {
  print('Failed to get fingerprint ID: $e');
}
```

### Listen to SDK Callbacks

```dart
import 'dart:async';

StreamSubscription<TrackingCallback>? subscription;

void setupCallbackListener() {
  subscription = sdk.addCallbackListener((callback) {
    print('Received callback: ${callback.callbackType}');
    print('Data: ${callback.data}');

    // Handle different callback types
    switch (callback.callbackType) {
      case 'install_referrer':
        // Handle install referrer callback
        break;
      case 'deep_link':
        // Handle deep link callback
        break;
      default:
        // Handle other callbacks
        break;
    }
  });
}

void dispose() {
  subscription?.cancel();
}
```

### Deep Link Handling (iOS)

For iOS deep link handling, call `onNewURL` when your app receives a new URL:

```dart
// In your app's deep link handler
await sdk.onNewURL('https://yourdomain.com/abc123');
```

### App Lifecycle Events

```dart
// Call when app resumes from background
await sdk.onAppResume();

// Reset first install flag (for testing)
await sdk.resetFirstInstall();
```

## API Reference

### FlutterInhouse

The main class for interacting with the TryInhouse SDK.

#### Methods

| Method                 | Parameters                                                                        | Return Type                            | Description                           |
| ---------------------- | --------------------------------------------------------------------------------- | -------------------------------------- | ------------------------------------- |
| `initialize`           | `projectToken`, `tokenId`, `shortLinkDomain`, `serverUrl?`, `enableDebugLogging?` | `Future<String>`                       | Initialize the SDK                    |
| `trackAppOpen`         | `shortLink?`                                                                      | `Future<String>`                       | Track app open event                  |
| `trackSessionStart`    | `shortLink?`                                                                      | `Future<String>`                       | Track session start                   |
| `trackShortLinkClick`  | `shortLink`, `deepLink?`                                                          | `Future<String>`                       | Track short link click                |
| `getInstallReferrer`   | -                                                                                 | `Future<String>`                       | Get install referrer                  |
| `fetchInstallReferrer` | -                                                                                 | `Future<String>`                       | Fetch install referrer                |
| `getFingerprint`       | -                                                                                 | `Future<String>`                       | Get device fingerprint (Android only) |
| `getFingerprintId`     | `algorithm?`                                                                      | `Future<String>`                       | Get fingerprint ID (Android only)     |
| `onAppResume`          | -                                                                                 | `Future<void>`                         | Handle app resume                     |
| `onNewURL`             | `url`                                                                             | `Future<void>`                         | Handle new URL (iOS only)             |
| `resetFirstInstall`    | -                                                                                 | `Future<void>`                         | Reset first install flag              |
| `addCallbackListener`  | `callback`                                                                        | `StreamSubscription<TrackingCallback>` | Listen to callbacks                   |

### TrackingCallback

Represents a callback from the native SDK.

#### Properties

| Property       | Type     | Description                            |
| -------------- | -------- | -------------------------------------- |
| `callbackType` | `String` | Type of callback                       |
| `data`         | `String` | JSON data associated with the callback |

## Error Handling

The plugin uses standard Dart exceptions. Wrap SDK calls in try-catch blocks:

```dart
try {
  await sdk.initialize(/* parameters */);
} on PlatformException catch (e) {
  print('Platform error: ${e.code} - ${e.message}');
} catch (e) {
  print('General error: $e');
}
```

## Platform Support

| Platform | Minimum Version | Features                              |
| -------- | --------------- | ------------------------------------- |
| iOS      | 16.0+           | All features except fingerprinting    |
| Android  | API 24+         | All features including fingerprinting |

## Example

Check out the [example app](example/) for a complete demonstration of all SDK features.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support and questions, please contact [support@tryinhouse.co](mailto:support@tryinhouse.co).

## Links

- [TryInhouse Website](https://tryinhouse.co)
- [Documentation](https://docs.tryinhouse.co)
- [GitHub Repository](https://github.com/28harishkumar/flutter_inhouse)
