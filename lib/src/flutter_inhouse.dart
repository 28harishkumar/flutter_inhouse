import 'dart:async';
import 'flutter_inhouse_platform.dart';
import 'models/tracking_callback.dart';

/// The main Flutter SDK class for TryInhouse tracking
class FlutterInhouse {
  static FlutterInhouse? _instance;
  static FlutterInhouse get instance => _instance ??= FlutterInhouse._();
  
  FlutterInhouse._();
  
  /// Gets the platform interface instance
  FlutterInhousePlatform get _platform => FlutterInhousePlatform.instance;
  
  /// Stream controller for SDK callbacks
  StreamController<TrackingCallback>? _callbackController;
  StreamSubscription<TrackingCallback>? _callbackSubscription;
  
  /// Initialize the tracking SDK with the provided configuration
  /// 
  /// [projectToken] - Your project token from TryInhouse dashboard
  /// [tokenId] - Your token ID from TryInhouse dashboard  
  /// [shortLinkDomain] - Your short link domain (e.g., "yourdomain.com")
  /// [serverUrl] - Optional custom server URL (defaults to TryInhouse API)
  /// [enableDebugLogging] - Enable debug logging for troubleshooting
  /// 
  /// Returns a Future<String> with initialization result
  Future<String> initialize({
    required String projectToken,
    required String tokenId,
    required String shortLinkDomain,
    String? serverUrl,
    bool enableDebugLogging = false,
  }) {
    return _platform.initialize(
      projectToken: projectToken,
      tokenId: tokenId,
      shortLinkDomain: shortLinkDomain,
      serverUrl: serverUrl,
      enableDebugLogging: enableDebugLogging,
    );
  }

  /// Called when the app resumes from background
  /// This helps track app sessions accurately
  Future<void> onAppResume() {
    return _platform.onAppResume();
  }

  /// Called when a new URL is received (iOS only)
  /// This is used for deep link handling on iOS
  Future<void> onNewURL(String url) {
    return _platform.onNewURL(url);
  }

  /// Track app open event
  /// 
  /// [shortLink] - Optional short link that caused the app open
  /// 
  /// Returns a Future<String> with the tracking response JSON
  Future<String> trackAppOpen({String? shortLink}) {
    return _platform.trackAppOpen(shortLink: shortLink);
  }

  /// Track session start event
  /// 
  /// [shortLink] - Optional short link that started the session
  /// 
  /// Returns a Future<String> with the tracking response JSON
  Future<String> trackSessionStart({String? shortLink}) {
    return _platform.trackSessionStart(shortLink: shortLink);
  }

  /// Track short link click event
  /// 
  /// [shortLink] - The short link that was clicked
  /// [deepLink] - Optional deep link associated with the short link
  /// 
  /// Returns a Future<String> with the tracking response JSON
  Future<String> trackShortLinkClick({
    required String shortLink,
    String? deepLink,
  }) {
    return _platform.trackShortLinkClick(
      shortLink: shortLink,
      deepLink: deepLink,
    );
  }

  /// Get the install referrer data
  /// 
  /// Returns a Future<String> with the install referrer data
  Future<String> getInstallReferrer() {
    return _platform.getInstallReferrer();
  }

  /// Fetch install referrer data from the platform
  /// This actively queries the platform for referrer data
  /// 
  /// Returns a Future<String> with the fetched install referrer data
  Future<String> fetchInstallReferrer() {
    return _platform.fetchInstallReferrer();
  }

  /// Reset first install flag for testing purposes
  /// This is useful during development and testing
  Future<void> resetFirstInstall() {
    return _platform.resetFirstInstall();
  }

  /// Get device fingerprint (Android only)
  /// 
  /// Returns a Future<String> with the device fingerprint, empty string on iOS
  Future<String> getFingerprint() {
    return _platform.getFingerprint();
  }

  /// Get fingerprint ID with optional algorithm (Android only)
  /// 
  /// [algorithm] - Optional algorithm for fingerprint generation
  /// 
  /// Returns a Future<String> with the fingerprint ID, empty string on iOS
  Future<String> getFingerprintId({String? algorithm}) {
    return _platform.getFingerprintId(algorithm: algorithm);
  }

  /// Listen to callbacks from the native SDK
  /// 
  /// [onCallback] - Function called when a callback is received
  /// 
  /// Returns a StreamSubscription that can be cancelled
  StreamSubscription<TrackingCallback> addCallbackListener(
    void Function(TrackingCallback callback) onCallback,
  ) {
    return _platform.callbackStream.listen(onCallback);
  }

  /// Get a stream of callbacks from the native SDK
  /// This provides a more flexible way to listen to callbacks
  Stream<TrackingCallback> get callbackStream => _platform.callbackStream;
} 