package com.example.status_saver

import android.content.Context
import android.media.MediaScannerConnection
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

object MediaScannerPlugin {
    private const val CHANNEL = "com.example.status_saver/media_scanner"

    fun register(flutterEngine: FlutterEngine, context: Context) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "scanFile" -> {
                    val path = call.argument<String>("path")
                    if (path != null) {
                        MediaScannerConnection.scanFile(
                            context,
                            arrayOf(path),
                            null
                        ) { _, uri ->
                            result.success(uri?.toString())
                        }
                    } else {
                        result.error("INVALID_PATH", "Path is null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}