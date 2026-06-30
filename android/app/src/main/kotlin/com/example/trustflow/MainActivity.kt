package com.example.trustflow

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.trustflow/secrets"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        System.loadLibrary("secrets")

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getUrl" -> result.success(getSupabaseUrl())
                    "getKey" -> result.success(getAnonKey())
                    else -> result.notImplemented()
                }
            }
    }

    private external fun getSupabaseUrl(): String
    private external fun getAnonKey(): String
}