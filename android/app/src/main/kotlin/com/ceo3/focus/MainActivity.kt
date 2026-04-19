package com.ceo3.focus

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.os.Build
import android.app.usage.UsageStatsManager
import android.app.usage.UsageStats
import android.content.Context
import java.util.*

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.ceo3.focus/blocking"
    private val USAGE_CHANNEL = "com.ceo3.focus/usage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startStrictBlock" -> {
                    val packages = call.argument<List<String>>("packages")
                    val limitPackages = call.argument<List<String>>("limitPackages")
                    val limitSeconds = call.argument<List<Int>>("limitSeconds")
                    val mode = call.argument<String>("mode") ?: "deep"
                    val intent = Intent(this, StrictBlockService::class.java)
                    intent.putExtra("packages", packages?.toTypedArray())
                    intent.putStringArrayListExtra("limitPackages", limitPackages?.let { ArrayList(it) })
                    intent.putIntegerArrayListExtra("limitSeconds", limitSeconds?.let { ArrayList(it) })
                    intent.putExtra("mode", mode)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(intent)
                    } else {
                        startService(intent)
                    }
                    result.success(true)
                }
                "stopStrictBlock" -> {
                    stopService(Intent(this, StrictBlockService::class.java))
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, USAGE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getUsageStats" -> {
                    getUsageStats(result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getUsageStats(result: MethodChannel.Result) {
        try {
            val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
            val calendar = Calendar.getInstance()
            calendar.set(Calendar.HOUR_OF_DAY, 0)
            calendar.set(Calendar.MINUTE, 0)
            calendar.set(Calendar.SECOND, 0)
            calendar.set(Calendar.MILLISECOND, 0)
            val startTime = calendar.timeInMillis
            val endTime = System.currentTimeMillis()

            val statsMap = usageStatsManager.queryAndAggregateUsageStats(startTime, endTime)

            val stats = mutableListOf<Map<String, Any>>()
            for ((packageName, usageStats) in statsMap) {
                val map = mapOf(
                    "packageName" to packageName,
                    "totalTimeInForeground" to usageStats.totalTimeInForeground,
                    "lastTimeUsed" to usageStats.lastTimeUsed
                )
                stats.add(map)
            }
            result.success(stats)
        } catch (e: Exception) {
            result.error("USAGE_ERROR", "Failed to get usage stats", e.message)
        }
    }
}
