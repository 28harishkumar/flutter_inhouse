import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'flutter_inhouse_platform.dart';
import 'models/tracking_callback.dart';

/// An implementation of [FlutterInhousePlatform] that uses method channels.
class MethodChannelFlutterInhouse extends FlutterInhousePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_inhouse');

  /// The event channel used to receive callbacks from the native platform.
  @visibleForTesting
  final eventChannel = const EventChannel('flutter_inhouse/callbacks');

  Stream<TrackingCallback>? _callbackStream;

  @override
  Future<String> initialize({
    required String projectToken,
    required String tokenId,
    required String shortLinkDomain,
    String? serverUrl,
    bool enableDebugLogging = false,
  }) async {
    final result = await methodChannel.invokeMethod<String>('initialize', {
      'projectToken': projectToken,
      'tokenId': tokenId,
      'shortLinkDomain': shortLinkDomain,
      'serverUrl': serverUrl,
      'enableDebugLogging': enableDebugLogging,
    });
    return result ?? 'Initialization failed';
  }

  @override
  Future<void> onAppResume() async {
    await methodChannel.invokeMethod<void>('onAppResume');
  }

  @override
  Future<void> onNewURL(String url) async {
    if (Platform.isIOS) {
      await methodChannel.invokeMethod<void>('onNewURL', {'url': url});
    }
  }

  @override
  Future<String> trackAppOpen({String? shortLink}) async {
    final result = await methodChannel.invokeMethod<String>('trackAppOpen', {
      'shortLink': shortLink,
    });
    return result ?? '';
  }

  @override
  Future<String> trackSessionStart({String? shortLink}) async {
    final result = await methodChannel.invokeMethod<String>('trackSessionStart', {
      'shortLink': shortLink,
    });
    return result ?? '';
  }

  @override
  Future<String> trackShortLinkClick({
    required String shortLink,
    String? deepLink,
  }) async {
    final result = await methodChannel.invokeMethod<String>('trackShortLinkClick', {
      'shortLink': shortLink,
      'deepLink': deepLink,
    });
    return result ?? '';
  }

  @override
  Future<String> getInstallReferrer() async {
    final result = await methodChannel.invokeMethod<String>('getInstallReferrer');
    return result ?? '';
  }

  @override
  Future<String> fetchInstallReferrer() async {
    final result = await methodChannel.invokeMethod<String>('fetchInstallReferrer');
    return result ?? '';
  }

  @override
  Future<void> resetFirstInstall() async {
    await methodChannel.invokeMethod<void>('resetFirstInstall');
  }

  @override
  Future<String> getFingerprint() async {
    if (Platform.isAndroid) {
      final result = await methodChannel.invokeMethod<String>('getFingerprint');
      return result ?? '';
    }
    return '';
  }

  @override
  Future<String> getFingerprintId({String? algorithm}) async {
    if (Platform.isAndroid) {
      final result = await methodChannel.invokeMethod<String>('getFingerprintId', {
        'algorithm': algorithm,
      });
      return result ?? '';
    }
    return '';
  }

  @override
  Stream<TrackingCallback> get callbackStream {
    _callbackStream ??= eventChannel
        .receiveBroadcastStream()
        .map((dynamic event) {
          if (event is Map<dynamic, dynamic>) {
            return TrackingCallback.fromMap(Map<String, dynamic>.from(event));
          }
          throw PlatformException(
            code: 'INVALID_EVENT',
            message: 'Received invalid event format: $event',
          );
        });
    return _callbackStream!;
  }
} 