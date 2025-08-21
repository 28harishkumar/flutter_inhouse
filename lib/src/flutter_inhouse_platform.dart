import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'flutter_inhouse_method_channel.dart';
import 'models/tracking_callback.dart';

/// The interface that implementations of flutter_inhouse must implement.
///
/// Platform implementations should extend this class rather than implement it
/// as `FlutterInhouse` does not consider newly added methods to be breaking
/// changes. Extending this class (using `extends`) ensures that the subclass
/// will get the default implementation, while platform implementations that
/// `implements` this interface will be broken by newly added
/// [FlutterInhousePlatform] methods.
abstract class FlutterInhousePlatform extends PlatformInterface {
  /// Constructs a FlutterInhousePlatform.
  FlutterInhousePlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterInhousePlatform _instance = MethodChannelFlutterInhouse();

  /// The default instance of [FlutterInhousePlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterInhouse].
  static FlutterInhousePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterInhousePlatform] when
  /// they register themselves.
  static set instance(FlutterInhousePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Initialize the tracking SDK with the provided configuration
  Future<String> initialize({
    required String projectToken,
    required String tokenId,
    required String shortLinkDomain,
    String? serverUrl,
    bool enableDebugLogging = false,
  }) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  /// Called when the app resumes from background
  Future<void> onAppResume() {
    throw UnimplementedError('onAppResume() has not been implemented.');
  }

  /// Called when a new URL is received (iOS only)
  Future<void> onNewURL(String url) {
    throw UnimplementedError('onNewURL() has not been implemented.');
  }

  /// Track app open event
  Future<String> trackAppOpen({String? shortLink}) {
    throw UnimplementedError('trackAppOpen() has not been implemented.');
  }

  /// Track session start event
  Future<String> trackSessionStart({String? shortLink}) {
    throw UnimplementedError('trackSessionStart() has not been implemented.');
  }

  /// Track short link click event
  Future<String> trackShortLinkClick({
    required String shortLink,
    String? deepLink,
  }) {
    throw UnimplementedError('trackShortLinkClick() has not been implemented.');
  }

  /// Get the install referrer data
  Future<String> getInstallReferrer() {
    throw UnimplementedError('getInstallReferrer() has not been implemented.');
  }

  /// Fetch install referrer data from the platform
  Future<String> fetchInstallReferrer() {
    throw UnimplementedError('fetchInstallReferrer() has not been implemented.');
  }

  /// Reset first install flag for testing purposes
  Future<void> resetFirstInstall() {
    throw UnimplementedError('resetFirstInstall() has not been implemented.');
  }

  /// Get device fingerprint (Android only)
  Future<String> getFingerprint() {
    throw UnimplementedError('getFingerprint() has not been implemented.');
  }

  /// Get fingerprint ID with optional algorithm (Android only)
  Future<String> getFingerprintId({String? algorithm}) {
    throw UnimplementedError('getFingerprintId() has not been implemented.');
  }

  /// Stream of callbacks from the native SDK
  Stream<TrackingCallback> get callbackStream {
    throw UnimplementedError('callbackStream has not been implemented.');
  }
} 