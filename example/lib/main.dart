import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inhouse/flutter_inhouse.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Inhouse SDK Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Inhouse SDK Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FlutterInhouse _sdk = FlutterInhouse.instance;
  String _status = 'Not initialized';
  List<String> _logs = [];
  StreamSubscription<TrackingCallback>? _callbackSubscription;
  bool _isInitialized = false;

  // Configuration - Replace with your actual values
  final String _projectToken = 'your_project_token';
  final String _tokenId = 'your_token_id';
  final String _shortLinkDomain = 'your_domain.com';
  final String _serverUrl = 'https://api.tryinhouse.co';

  @override
  void initState() {
    super.initState();
    _setupCallbackListener();
  }

  @override
  void dispose() {
    _callbackSubscription?.cancel();
    super.dispose();
  }

  void _setupCallbackListener() {
    _callbackSubscription = _sdk.addCallbackListener((callback) {
      _addLog('Callback received: ${callback.callbackType} - ${callback.data}');
    });
  }

  void _addLog(String message) {
    setState(() {
      _logs.insert(0, '${DateTime.now().toString().substring(11, 19)}: $message');
      if (_logs.length > 50) {
        _logs.removeLast();
      }
    });
  }

  Future<void> _initialize() async {
    try {
      setState(() {
        _status = 'Initializing...';
      });

      final result = await _sdk.initialize(
        projectToken: _projectToken,
        tokenId: _tokenId,
        shortLinkDomain: _shortLinkDomain,
        serverUrl: _serverUrl,
        enableDebugLogging: true,
      );

      setState(() {
        _status = 'Initialized: $result';
        _isInitialized = true;
      });
      _addLog('SDK initialized successfully');
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
      _addLog('Initialization error: $e');
    }
  }

  Future<void> _trackAppOpen() async {
    if (!_isInitialized) {
      _addLog('SDK not initialized');
      return;
    }

    try {
      final result = await _sdk.trackAppOpen();
      _addLog('App open tracked: $result');
    } catch (e) {
      _addLog('Error tracking app open: $e');
    }
  }

  Future<void> _trackSessionStart() async {
    if (!_isInitialized) {
      _addLog('SDK not initialized');
      return;
    }

    try {
      final result = await _sdk.trackSessionStart();
      _addLog('Session start tracked: $result');
    } catch (e) {
      _addLog('Error tracking session start: $e');
    }
  }

  Future<void> _trackShortLinkClick() async {
    if (!_isInitialized) {
      _addLog('SDK not initialized');
      return;
    }

    try {
      final result = await _sdk.trackShortLinkClick(
        shortLink: 'https://$_shortLinkDomain/test123',
        deepLink: 'myapp://home',
      );
      _addLog('Short link click tracked: $result');
    } catch (e) {
      _addLog('Error tracking short link click: $e');
    }
  }

  Future<void> _getInstallReferrer() async {
    if (!_isInitialized) {
      _addLog('SDK not initialized');
      return;
    }

    try {
      final result = await _sdk.getInstallReferrer();
      _addLog('Install referrer: $result');
    } catch (e) {
      _addLog('Error getting install referrer: $e');
    }
  }

  Future<void> _fetchInstallReferrer() async {
    if (!_isInitialized) {
      _addLog('SDK not initialized');
      return;
    }

    try {
      final result = await _sdk.fetchInstallReferrer();
      _addLog('Fetched install referrer: $result');
    } catch (e) {
      _addLog('Error fetching install referrer: $e');
    }
  }

  Future<void> _getFingerprint() async {
    if (!_isInitialized) {
      _addLog('SDK not initialized');
      return;
    }

    try {
      final result = await _sdk.getFingerprint();
      if (result.isNotEmpty) {
        _addLog('Device fingerprint: ${result.substring(0, 20)}...');
      } else {
        _addLog('Fingerprint not available (iOS or not supported)');
      }
    } catch (e) {
      _addLog('Error getting fingerprint: $e');
    }
  }

  Future<void> _getFingerprintId() async {
    if (!_isInitialized) {
      _addLog('SDK not initialized');
      return;
    }

    try {
      final result = await _sdk.getFingerprintId();
      if (result.isNotEmpty) {
        _addLog('Fingerprint ID: $result');
      } else {
        _addLog('Fingerprint ID not available (iOS or not supported)');
      }
    } catch (e) {
      _addLog('Error getting fingerprint ID: $e');
    }
  }

  Future<void> _onAppResume() async {
    if (!_isInitialized) {
      _addLog('SDK not initialized');
      return;
    }

    try {
      await _sdk.onAppResume();
      _addLog('App resume event sent');
    } catch (e) {
      _addLog('Error sending app resume: $e');
    }
  }

  Future<void> _resetFirstInstall() async {
    if (!_isInitialized) {
      _addLog('SDK not initialized');
      return;
    }

    try {
      await _sdk.resetFirstInstall();
      _addLog('First install flag reset');
    } catch (e) {
      _addLog('Error resetting first install: $e');
    }
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearLogs,
            tooltip: 'Clear logs',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: $_status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Configuration:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text('Project Token: $_projectToken'),
                Text('Token ID: $_tokenId'),
                Text('Short Link Domain: $_shortLinkDomain'),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  ElevatedButton(
                    onPressed: _isInitialized ? null : _initialize,
                    child: const Text('Initialize SDK'),
                  ),
                  ElevatedButton(
                    onPressed: _trackAppOpen,
                    child: const Text('Track App Open'),
                  ),
                  ElevatedButton(
                    onPressed: _trackSessionStart,
                    child: const Text('Track Session Start'),
                  ),
                  ElevatedButton(
                    onPressed: _trackShortLinkClick,
                    child: const Text('Track Short Link Click'),
                  ),
                  ElevatedButton(
                    onPressed: _getInstallReferrer,
                    child: const Text('Get Install Referrer'),
                  ),
                  ElevatedButton(
                    onPressed: _fetchInstallReferrer,
                    child: const Text('Fetch Install Referrer'),
                  ),
                  ElevatedButton(
                    onPressed: _getFingerprint,
                    child: const Text('Get Fingerprint'),
                  ),
                  ElevatedButton(
                    onPressed: _getFingerprintId,
                    child: const Text('Get Fingerprint ID'),
                  ),
                  ElevatedButton(
                    onPressed: _onAppResume,
                    child: const Text('On App Resume'),
                  ),
                  ElevatedButton(
                    onPressed: _resetFirstInstall,
                    child: const Text('Reset First Install'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              margin: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        topRight: Radius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Logs',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            _logs[index],
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12.0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 