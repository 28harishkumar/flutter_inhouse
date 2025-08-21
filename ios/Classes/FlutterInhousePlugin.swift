import Flutter
import UIKit
import InhouseTrackingSDK

public class FlutterInhousePlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var methodChannel: FlutterMethodChannel?
    private var eventChannel: FlutterEventChannel?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = FlutterInhousePlugin()
        
        let methodChannel = FlutterMethodChannel(
            name: "flutter_inhouse",
            binaryMessenger: registrar.messenger()
        )
        instance.methodChannel = methodChannel
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        
        let eventChannel = FlutterEventChannel(
            name: "flutter_inhouse/callbacks",
            binaryMessenger: registrar.messenger()
        )
        instance.eventChannel = eventChannel
        eventChannel.setStreamHandler(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            handleInitialize(call, result: result)
        case "onAppResume":
            handleOnAppResume(call, result: result)
        case "onNewURL":
            handleOnNewURL(call, result: result)
        case "trackAppOpen":
            handleTrackAppOpen(call, result: result)
        case "trackSessionStart":
            handleTrackSessionStart(call, result: result)
        case "trackShortLinkClick":
            handleTrackShortLinkClick(call, result: result)
        case "getInstallReferrer":
            handleGetInstallReferrer(call, result: result)
        case "fetchInstallReferrer":
            handleFetchInstallReferrer(call, result: result)
        case "resetFirstInstall":
            handleResetFirstInstall(call, result: result)
        case "getFingerprint":
            // iOS doesn't support fingerprinting, return empty string
            result("")
        case "getFingerprintId":
            // iOS doesn't support fingerprinting, return empty string
            result("")
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - FlutterStreamHandler
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
    
    // MARK: - Method Handlers
    
    private func handleInitialize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let projectToken = args["projectToken"] as? String,
              let tokenId = args["tokenId"] as? String,
              let shortLinkDomain = args["shortLinkDomain"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required arguments", details: nil))
            return
        }
        
        let serverUrl = args["serverUrl"] as? String
        let enableDebugLogging = args["enableDebugLogging"] as? Bool ?? false
        
        DispatchQueue.main.async {
            InhouseTrackingSDK.shared.initialize(
                projectId: tokenId,
                projectToken: projectToken,
                shortLinkDomain: shortLinkDomain,
                serverUrl: serverUrl,
                enableDebugLogging: enableDebugLogging
            ) { [weak self] callbackType, data in
                self?.sendEvent(callbackType: callbackType, data: data)
            }
            result("SDK initialized successfully")
        }
    }
    
    private func handleOnAppResume(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            InhouseTrackingSDK.shared.onAppResume()
            result(nil)
        }
    }
    
    private func handleOnNewURL(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let urlString = args["url"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing URL argument", details: nil))
            return
        }
        
        DispatchQueue.main.async {
            let url = URL(string: urlString)
            InhouseTrackingSDK.shared.onNewURL(url)
            result(nil)
        }
    }
    
    private func handleTrackAppOpen(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any]
        let shortLink = args?["shortLink"] as? String
        
        DispatchQueue.main.async {
            InhouseTrackingSDK.shared.trackAppOpen(shortLink: shortLink) { responseJson in
                result(responseJson)
            }
        }
    }
    
    private func handleTrackSessionStart(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any]
        let shortLink = args?["shortLink"] as? String
        
        DispatchQueue.main.async {
            InhouseTrackingSDK.shared.trackSessionStart(shortLink: shortLink) { responseJson in
                result(responseJson)
            }
        }
    }
    
    private func handleTrackShortLinkClick(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let shortLink = args["shortLink"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing shortLink argument", details: nil))
            return
        }
        
        let deepLink = args["deepLink"] as? String
        
        DispatchQueue.main.async {
            InhouseTrackingSDK.shared.trackShortLinkClick(shortLink: shortLink, deepLink: deepLink) { responseJson in
                result(responseJson)
            }
        }
    }
    
    private func handleGetInstallReferrer(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            let installReferrer = InhouseTrackingSDK.shared.getInstallReferrer()
            result(installReferrer ?? "")
        }
    }
    
    private func handleFetchInstallReferrer(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            InhouseTrackingSDK.shared.fetchInstallReferrer { referrer in
                result(referrer ?? "")
            }
        }
    }
    
    private func handleResetFirstInstall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            InhouseTrackingSDK.shared.resetFirstInstall()
            result(nil)
        }
    }
    
    // MARK: - Helper Methods
    
    private func sendEvent(callbackType: String, data: String) {
        guard let eventSink = self.eventSink else { return }
        
        let eventData: [String: Any] = [
            "callbackType": callbackType,
            "data": data
        ]
        
        DispatchQueue.main.async {
            eventSink(eventData)
        }
    }
} 