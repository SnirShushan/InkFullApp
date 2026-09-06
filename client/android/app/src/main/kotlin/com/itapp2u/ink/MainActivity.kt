package com.itapp2u.ink

import android.os.Build
import android.os.Bundle
import android.widget.Toast
import com.facebook.FacebookSdk
import com.facebook.appevents.AppEventsLogger
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import java.util.Currency

class MainActivity: FlutterActivity() {

//    private val CHANNEL = "deviceInfoChannel"
    private val CHANNEL = "ink.itapp2u.com/fb_events"
    private lateinit var logger: AppEventsLogger

   /* override fun configureFlutterEngine(@NonNull flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        logger = AppEventsLogger.newLogger(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAndroidVersion" -> getAppVersion(call,result)
                "logEvent" -> logEvent(call, result)
                "handlePurchase" -> handlePurchased(call, result)
                else -> result.notImplemented()
            }
        }
    }*/

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

//        AppEventsLogger.activateApp(this,"com.itapp2u.ink")
        FacebookSdk.setAutoLogAppEventsEnabled(true)
        logger = AppEventsLogger.newLogger(this)
        // Set up platform channel
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAndroidVersion" -> getAppVersion(call,result)
                "logEvent" -> handleLogEvent(call, result)
                "handlePurchase" -> handlePurchased(call, result)
                else -> result.notImplemented()
            }
        }
    }


    private fun handleLogEvent(call: MethodCall, result: Result) {
        val eventName = call.argument("name") as? String
        val parameters = call.argument("parameters") as? Map<String, Object>
        val valueToSum = call.argument("_valueToSum") as? Double

        if (valueToSum != null && parameters != null) {
            val parameterBundle = createBundleFromMap(parameters)
            logger.logEvent(eventName, valueToSum, parameterBundle)
//        } else if (valueToSum != null) {
//            logger.logEvent(eventName, valueToSum)
        } else if (parameters != null) {
            val parameterBundle = createBundleFromMap(parameters)
            logger.logEvent(eventName, parameterBundle)
        } else {
            logger.logEvent(eventName)
        }

        result.success(null)
    }

    private fun createBundleFromMap(parameterMap: Map<String, Any>?): Bundle? {
        if (parameterMap == null) {
            return null
        }

        val bundle = Bundle()
        for (jsonParam in parameterMap.entries) {
            val value = jsonParam.value
            val key = jsonParam.key
            if (value is String) {
                bundle.putString(key, value as String)
            } else if (value is Int) {
                bundle.putInt(key, value as Int)
            } else if (value is Long) {
                bundle.putLong(key, value as Long)
            } else if (value is Double) {
                bundle.putDouble(key, value as Double)
            } else if (value is Boolean) {
                bundle.putBoolean(key, value as Boolean)
            } else if (value is Map<*, *>) {
                val nestedBundle = createBundleFromMap(value as Map<String, Any>)
                bundle.putBundle(key, nestedBundle as Bundle)
            } else {
                throw IllegalArgumentException(
                    "Unsupported value type: " + value.javaClass.kotlin)
            }
        }
        return bundle
    }


    private fun getAppVersion(call: MethodCall, result: MethodChannel.Result) {
        val version = Build.VERSION.SDK_INT
        result.success(version)
    }

    /*private fun logEvent(call: MethodCall, result: MethodChannel.Result) {
        val eventName = call.argument<String>("eventName")
        val parameters = call.argument<HashMap<String, Any>>("parameters")
        if (eventName != null) {
            if (parameters != null) {
                logger.logEvent(eventName, Bundle().apply {
                    parameters.forEach { (key, value) -> putString(key, value.toString()) }
                })
            } else {
                logger.logEvent(eventName)
            }
            result.success("Event logged: $eventName")
        } else {
            result.error("INVALID_EVENT", "Event name is required", null)
        }
    }*/

    private fun handlePurchased(call: MethodCall, result: MethodChannel.Result) {
        var amount = (call.argument("amount") as? Double)?.toBigDecimal()
        var currency = Currency.getInstance(call.argument("currency") as? String)
        val parameters = call.argument("parameters") as? Map<String, Object>
        val parameterBundle = Bundle().apply {
            parameters?.forEach { (key, value) -> putString(key, value.toString()) }
        }

//        Toast.makeText(context,""+amount,Toast.LENGTH_SHORT).show()
//        Toast.makeText(context,""+currency,Toast.LENGTH_SHORT).show()

        logger.logPurchase(amount, currency, parameterBundle)
        result.success(null)
    }
}