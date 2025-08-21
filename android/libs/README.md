# TryInhouse Android SDK Distribution

This directory contains the distributable artifacts for the TryInhouse Android SDK.

## Files Included

- `client-release.aar` - The main SDK library (Android Archive)
- `client-javadoc.jar` - API documentation in Javadoc format
- `client-sources.jar` - Source code for debugging and reference
- `proguard-rules.pro` - ProGuard rules for the SDK
- `consumer-rules.pro` - Consumer ProGuard rules for apps using the SDK
- `dokka/` - Detailed API documentation generated with Dokka (if available)

## Integration Guide

### Gradle Integration

1. Copy the `client-release.aar` file to your app's `libs` directory
2. Add the following to your app's `build.gradle` file:

```gradle
android {
    // ... your existing configuration
}

dependencies {
    // Add the TryInhouse SDK
    implementation files('libs/client-release.aar')
    
    // Required dependencies for the SDK
    implementation 'com.squareup.okhttp3:okhttp:4.12.0'
    implementation 'com.google.code.gson:gson:2.10.1'
    implementation 'com.android.installreferrer:installreferrer:2.2'
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3'
    implementation 'com.github.thumbmarkjs:thumbmark-android:1.0.+'
    
    // Standard Android dependencies
    implementation 'androidx.core:core-ktx:1.12.0'
    implementation 'androidx.appcompat:appcompat:1.6.1'
}

repositories {
    // Add JitPack for thumbmark dependency
    maven { url 'https://jitpack.io' }
}
```

3. Copy the ProGuard rules to your app if you're using ProGuard/R8:
   - Add contents of `proguard-rules.pro` to your app's ProGuard configuration
   - The `consumer-rules.pro` will be automatically applied when you include the AAR

### Basic Usage

```kotlin
import co.tryinhouse.android.TrackingSDK

class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        
        // Initialize the SDK
        TrackingSDK.getInstance().initialize(
            context = this,
            projectToken = "your-project-token",
            tokenId = "your-token-id",
            shortLinkDomain = "yourdomain.link",
            serverUrl = "https://api.tryinhouse.co",
            enableDebugLogging = BuildConfig.DEBUG
        ) { callbackType, jsonData ->
            // Handle SDK callbacks
            Log.d("TrackingSDK", "Callback: $callbackType -> $jsonData")
        }
    }
}
```

### Activity Integration

```kotlin
class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Set current activity for SDK
        TrackingSDK.getInstance().setCurrentActivity(this)
    }
    
    override fun onResume() {
        super.onResume()
        TrackingSDK.getInstance().onAppResume()
    }
    
    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        TrackingSDK.getInstance().onNewIntent(intent)
    }
}
```

## API Documentation

- View the complete API documentation in the `dokka/` directory
- Open `dokka/index.html` in a web browser for detailed documentation
- The `client-javadoc.jar` contains standard Javadoc format documentation

## ProGuard Configuration

If you're using ProGuard or R8 for code obfuscation, make sure to include the rules from:
- `proguard-rules.pro` - Add these rules to your app's ProGuard configuration
- `consumer-rules.pro` - These are automatically applied when you include the AAR

## Dependencies

The SDK requires the following dependencies in your app:

- OkHttp 4.12.0+ for networking
- Gson 2.10.1+ for JSON parsing
- Android Install Referrer 2.2+ for attribution
- Kotlin Coroutines 1.7.3+ for async operations
- Thumbmark Android 1.0.+ for device fingerprinting

## Support

For technical support and documentation, visit: https://docs.tryinhouse.co

## Version Information

This distribution was built on: $(date)
SDK Version: 1.0.0
