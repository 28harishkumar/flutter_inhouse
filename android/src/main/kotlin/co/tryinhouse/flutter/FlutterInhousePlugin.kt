package co.tryinhouse.flutter

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import co.tryinhouse.android.TrackingSDK
import com.thumbmarkjs.thumbmark_android.Thumbmark
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterInhousePlugin */
class FlutterInhousePlugin: FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var context: Context? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_inhouse")
        methodChannel.setMethodCallHandler(this)
        
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "flutter_inhouse/callbacks")
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "initialize" -> handleInitialize(call, result)
            "onAppResume" -> handleOnAppResume(call, result)
            "onNewURL" -> {
                // Android doesn't need onNewURL, just return success
                result.success(null)
            }
            "trackAppOpen" -> handleTrackAppOpen(call, result)
            "trackSessionStart" -> handleTrackSessionStart(call, result)
            "trackShortLinkClick" -> handleTrackShortLinkClick(call, result)
            "getInstallReferrer" -> handleGetInstallReferrer(call, result)
            "fetchInstallReferrer" -> handleFetchInstallReferrer(call, result)
            "resetFirstInstall" -> handleResetFirstInstall(call, result)
            "getFingerprint" -> handleGetFingerprint(call, result)
            "getFingerprintId" -> handleGetFingerprintId(call, result)
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        context = null
    }

    // MARK: - EventChannel.StreamHandler

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    // MARK: - Method Handlers

    private fun handleInitialize(call: MethodCall, result: Result) {
        try {
            val projectToken = call.argument<String>("projectToken")
            val tokenId = call.argument<String>("tokenId")
            val shortLinkDomain = call.argument<String>("shortLinkDomain")
            val serverUrl = call.argument<String>("serverUrl")
            val enableDebugLogging = call.argument<Boolean>("enableDebugLogging") ?: false

            if (projectToken == null || tokenId == null || shortLinkDomain == null) {
                result.error("INVALID_ARGUMENTS", "Missing required arguments", null)
                return
            }

            val context = this.context
            if (context == null) {
                result.error("CONTEXT_NULL", "Android context is null", null)
                return
            }

            Log.d("FlutterInhousePlugin", "initialize called with projectToken=$projectToken, tokenId=$tokenId, shortLinkDomain=$shortLinkDomain, serverUrl=$serverUrl, enableDebugLogging=$enableDebugLogging")

            TrackingSDK.getInstance().initialize(
                context = context,
                projectToken = projectToken,
                tokenId = tokenId,
                shortLinkDomain = shortLinkDomain,
                serverUrl = serverUrl ?: "https://api.tryinhouse.co",
                enableDebugLogging = enableDebugLogging
            ) { callbackType, jsonData ->
                Log.d("FlutterInhousePlugin", "SDK callback: callbackType=$callbackType, data=$jsonData")
                sendEvent(callbackType, jsonData)
            }
            result.success("SDK initialized successfully")
        } catch (e: Exception) {
            Log.e("FlutterInhousePlugin", "Initialization error", e)
            result.error("INITIALIZATION_ERROR", e.message, null)
        }
    }

    private fun handleOnAppResume(call: MethodCall, result: Result) {
        try {
            TrackingSDK.getInstance().onAppResume()
            result.success(null)
        } catch (e: Exception) {
            result.error("APP_RESUME_ERROR", e.message, null)
        }
    }

    private fun handleTrackAppOpen(call: MethodCall, result: Result) {
        try {
            val shortLink = call.argument<String>("shortLink")
            TrackingSDK.getInstance().trackAppOpen(shortLink) { responseJson ->
                result.success(responseJson)
            }
        } catch (e: Exception) {
            result.error("TRACK_APP_OPEN_ERROR", e.message, null)
        }
    }

    private fun handleTrackSessionStart(call: MethodCall, result: Result) {
        try {
            val shortLink = call.argument<String>("shortLink")
            TrackingSDK.getInstance().trackSessionStart(shortLink) { responseJson ->
                result.success(responseJson)
            }
        } catch (e: Exception) {
            result.error("TRACK_SESSION_START_ERROR", e.message, null)
        }
    }

    private fun handleTrackShortLinkClick(call: MethodCall, result: Result) {
        try {
            val shortLink = call.argument<String>("shortLink")
            val deepLink = call.argument<String>("deepLink")
            
            if (shortLink == null) {
                result.error("INVALID_ARGUMENTS", "Missing shortLink argument", null)
                return
            }
            
            TrackingSDK.getInstance().trackShortLinkClick(shortLink, deepLink) { responseJson ->
                result.success(responseJson)
            }
        } catch (e: Exception) {
            result.error("TRACK_SHORT_LINK_CLICK_ERROR", e.message, null)
        }
    }

    private fun handleGetInstallReferrer(call: MethodCall, result: Result) {
        try {
            val installReferrer = TrackingSDK.getInstance().getInstallReferrer()
            result.success(installReferrer ?: "")
        } catch (e: Exception) {
            result.error("GET_INSTALL_REFERRER_ERROR", e.message, null)
        }
    }

    private fun handleFetchInstallReferrer(call: MethodCall, result: Result) {
        try {
            TrackingSDK.getInstance().fetchInstallReferrer { referrer ->
                result.success(referrer ?: "")
            }
        } catch (e: Exception) {
            result.error("FETCH_INSTALL_REFERRER_ERROR", e.message, null)
        }
    }

    private fun handleResetFirstInstall(call: MethodCall, result: Result) {
        try {
            TrackingSDK.getInstance().resetFirstInstall()
            result.success(null)
        } catch (e: Exception) {
            result.error("RESET_FIRST_INSTALL_ERROR", e.message, null)
        }
    }

    private fun handleGetFingerprint(call: MethodCall, result: Result) {
        try {
            val context = this.context
            if (context == null) {
                result.success("")
                return
            }
            
            val fingerprint = Thumbmark.fingerprint(context)
            result.success(fingerprint?.toString() ?: "")
        } catch (e: Exception) {
            Log.e("FlutterInhousePlugin", "Error getting fingerprint", e)
            result.success("")
        }
    }

    private fun handleGetFingerprintId(call: MethodCall, result: Result) {
        try {
            val context = this.context
            if (context == null) {
                result.success("")
                return
            }
            
            val algorithm = call.argument<String>("algorithm")
            val fingerprintId = if (algorithm != null) {
                Thumbmark.id(algorithm, context)
            } else {
                Thumbmark.id(context)
            }
            result.success(fingerprintId ?: "")
        } catch (e: Exception) {
            Log.e("FlutterInhousePlugin", "Error getting fingerprint ID", e)
            result.success("")
        }
    }

    // MARK: - Helper Methods

    private fun sendEvent(callbackType: String, data: String) {
        val eventData = mapOf(
            "callbackType" to callbackType,
            "data" to data
        )
        
        Handler(Looper.getMainLooper()).post {
            eventSink?.success(eventData)
        }
    }
} 