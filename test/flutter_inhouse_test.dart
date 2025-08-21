import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inhouse/flutter_inhouse.dart';
import 'package:flutter_inhouse/src/flutter_inhouse_platform.dart';
import 'package:flutter_inhouse/src/flutter_inhouse_method_channel.dart';
import 'package:flutter_inhouse/src/models/tracking_callback.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterInhousePlatform
    with MockPlatformInterfaceMixin
    implements FlutterInhousePlatform {

  @override
  Future<String> initialize({
    required String projectToken,
    required String tokenId,
    required String shortLinkDomain,
    String? serverUrl,
    bool enableDebugLogging = false,
  }) async {
    return 'SDK initialized successfully';
  }

  @override
  Future<void> onAppResume() async {
    return;
  }

  @override
  Future<void> onNewURL(String url) async {
    return;
  }

  @override
  Future<String> trackAppOpen({String? shortLink}) async {
    return '{"success": true, "tracked": "app_open"}';
  }

  @override
  Future<String> trackSessionStart({String? shortLink}) async {
    return '{"success": true, "tracked": "session_start"}';
  }

  @override
  Future<String> trackShortLinkClick({
    required String shortLink,
    String? deepLink,
  }) async {
    return '{"success": true, "tracked": "short_link_click"}';
  }

  @override
  Future<String> getInstallReferrer() async {
    return 'mock_install_referrer';
  }

  @override
  Future<String> fetchInstallReferrer() async {
    return 'fetched_install_referrer';
  }

  @override
  Future<void> resetFirstInstall() async {
    return;
  }

  @override
  Future<String> getFingerprint() async {
    return 'mock_fingerprint';
  }

  @override
  Future<String> getFingerprintId({String? algorithm}) async {
    return 'mock_fingerprint_id';
  }

  @override
  Stream<TrackingCallback> get callbackStream {
    return Stream.fromIterable([
      const TrackingCallback(
        callbackType: 'test_callback',
        data: '{"test": "data"}',
      ),
    ]);
  }
}

void main() {
  final FlutterInhousePlatform initialPlatform = FlutterInhousePlatform.instance;

  group('FlutterInhouse', () {
    late MockFlutterInhousePlatform mockPlatform;
    late FlutterInhouse sdk;

    setUp(() {
      mockPlatform = MockFlutterInhousePlatform();
      FlutterInhousePlatform.instance = mockPlatform;
      sdk = FlutterInhouse.instance;
    });

    tearDown(() {
      FlutterInhousePlatform.instance = initialPlatform;
    });

    test('initialize returns success message', () async {
      final result = await sdk.initialize(
        projectToken: 'test_token',
        tokenId: 'test_id',
        shortLinkDomain: 'test.com',
      );
      expect(result, 'SDK initialized successfully');
    });

    test('trackAppOpen returns JSON response', () async {
      final result = await sdk.trackAppOpen();
      expect(result, '{"success": true, "tracked": "app_open"}');
    });

    test('trackSessionStart returns JSON response', () async {
      final result = await sdk.trackSessionStart();
      expect(result, '{"success": true, "tracked": "session_start"}');
    });

    test('trackShortLinkClick returns JSON response', () async {
      final result = await sdk.trackShortLinkClick(
        shortLink: 'https://test.com/abc123',
      );
      expect(result, '{"success": true, "tracked": "short_link_click"}');
    });

    test('getInstallReferrer returns referrer data', () async {
      final result = await sdk.getInstallReferrer();
      expect(result, 'mock_install_referrer');
    });

    test('fetchInstallReferrer returns fetched referrer data', () async {
      final result = await sdk.fetchInstallReferrer();
      expect(result, 'fetched_install_referrer');
    });

    test('getFingerprint returns fingerprint data', () async {
      final result = await sdk.getFingerprint();
      expect(result, 'mock_fingerprint');
    });

    test('getFingerprintId returns fingerprint ID', () async {
      final result = await sdk.getFingerprintId();
      expect(result, 'mock_fingerprint_id');
    });

    test('callback stream emits TrackingCallback objects', () async {
      final stream = sdk.callbackStream;
      final callback = await stream.first;
      
      expect(callback.callbackType, 'test_callback');
      expect(callback.data, '{"test": "data"}');
    });

    test('onAppResume completes without error', () async {
      await expectLater(sdk.onAppResume(), completes);
    });

    test('onNewURL completes without error', () async {
      await expectLater(sdk.onNewURL('https://test.com/abc123'), completes);
    });

    test('resetFirstInstall completes without error', () async {
      await expectLater(sdk.resetFirstInstall(), completes);
    });
  });

  group('TrackingCallback', () {
    test('creates TrackingCallback from map', () {
      final map = {
        'callbackType': 'test_type',
        'data': 'test_data',
      };
      
      final callback = TrackingCallback.fromMap(map);
      
      expect(callback.callbackType, 'test_type');
      expect(callback.data, 'test_data');
    });

    test('converts TrackingCallback to map', () {
      const callback = TrackingCallback(
        callbackType: 'test_type',
        data: 'test_data',
      );
      
      final map = callback.toMap();
      
      expect(map['callbackType'], 'test_type');
      expect(map['data'], 'test_data');
    });

    test('TrackingCallback equality works correctly', () {
      const callback1 = TrackingCallback(
        callbackType: 'test_type',
        data: 'test_data',
      );
      
      const callback2 = TrackingCallback(
        callbackType: 'test_type',
        data: 'test_data',
      );
      
      const callback3 = TrackingCallback(
        callbackType: 'different_type',
        data: 'test_data',
      );
      
      expect(callback1, equals(callback2));
      expect(callback1, isNot(equals(callback3)));
    });

    test('TrackingCallback toString works correctly', () {
      const callback = TrackingCallback(
        callbackType: 'test_type',
        data: 'test_data',
      );
      
      final string = callback.toString();
      expect(string, contains('test_type'));
      expect(string, contains('test_data'));
    });
  });

  group('Platform interface', () {
    test('uses MethodChannelFlutterInhouse as default platform', () {
      expect(initialPlatform, isInstanceOf<MethodChannelFlutterInhouse>());
    });
  });
} 