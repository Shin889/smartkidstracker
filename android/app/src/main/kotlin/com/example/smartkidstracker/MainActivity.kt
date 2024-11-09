package com.example.smartkidstracker

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.annotation.NonNull

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.smartkidstracker/channel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getData" -> {
                    // Simulate getting data from native side
                    val data = "Hello from native Android!"
                    result.success(data)
                }
                else -> result.notImplemented()
            }
        }
    }
}