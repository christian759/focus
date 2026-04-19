package com.ceo3.focus

import android.app.*
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.TextView
import androidx.core.app.NotificationCompat

class StrictBlockService : Service() {
    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var isOverlayDisplayed = false
    private var handler: Handler? = null
    private var runnable: Runnable? = null
    private var blockedPackages = setOf<String>()
    private var limitPackages = mapOf<String, Int>()
    private var overLimitPackages = mutableSetOf<String>()
    private var lastUsageCheckTime = 0L
    private var mode: String = "deep"
    private var lastForegroundPackage: String? = null
    private var lastCheckTime: Long = 0L

    companion object {
        const val CHANNEL_ID = "StrictBlockChannel"
        const val NOTIFICATION_ID = 101
        var isRunning = false
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        isRunning = true
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        createNotificationChannel()
    }

    private fun createOverlayView() {
        val root = FrameLayout(this)
        root.setBackgroundColor(Color.parseColor("#121212")) // Default dark
        
        val container = android.widget.LinearLayout(this)
        container.orientation = android.widget.LinearLayout.VERTICAL
        container.gravity = Gravity.CENTER
        
        val titleView = TextView(this)
        titleView.text = when (mode) {
            "deep" -> "DEEP FOCUS ACTIVE"
            "passive", "doom" -> "MINDFUL INTERVENTION"
            else -> "APP LIMIT REACHED"
        }
        titleView.setTextColor(Color.parseColor("#64B5F6")) // Light blue accent
        titleView.textSize = 14f
        titleView.letterSpacing = 0.2f
        titleView.gravity = Gravity.CENTER
        container.addView(titleView)

        val spacing1 = View(this)
        container.addView(spacing1, FrameLayout.LayoutParams(10, 40))

        val textView = TextView(this)
        textView.text = if (mode == "doom") 
            "Is this scroll worth\nyour time?" 
            else "This app is restricted\nfor your focus."
        textView.setTextColor(Color.WHITE)
        textView.gravity = Gravity.CENTER
        textView.textSize = 28f
        textView.setTypeface(null, android.graphics.Typeface.BOLD)
        container.addView(textView)

        val spacing2 = View(this)
        container.addView(spacing2, FrameLayout.LayoutParams(10, 60))

        if (mode == "doom") {
            val subText = TextView(this)
            subText.text = "Take a breath. Reconnect."
            subText.setTextColor(Color.parseColor("#80FFFFFF"))
            subText.gravity = Gravity.CENTER
            subText.textSize = 16f
            container.addView(subText)
        } else {
            val subText = TextView(this)
            subText.text = "Finish your goal first."
            subText.setTextColor(Color.parseColor("#80FFFFFF"))
            subText.gravity = Gravity.CENTER
            subText.textSize = 16f
            container.addView(subText)
        }
        
        val lp = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.WRAP_CONTENT,
            Gravity.CENTER
        )
        root.addView(container, lp)
        overlayView = root
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(CHANNEL_ID, "Focus Blocking Service", NotificationManager.IMPORTANCE_LOW)
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val packages = intent?.getStringArrayExtra("packages")?.toSet() ?: emptySet()
        blockedPackages = packages
        
        val limitPkgs = intent?.getStringArrayListExtra("limitPackages") ?: arrayListOf()
        val limitSecs = intent?.getIntegerArrayListExtra("limitSeconds") ?: arrayListOf()
        limitPackages = limitPkgs.zip(limitSecs).toMap()
        
        // Always purge the "exceeded" cache on a fresh intent to ensure any newly increased config limits are respected
        overLimitPackages.clear()
        
        mode = intent?.getStringExtra("mode") ?: "deep"

        if (overlayView == null) {
            createOverlayView()
        }

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(when (mode) {
                "deep" -> "Deep Focus Active"
                "passive", "doom" -> "Passive Shield Active"
                else -> "App Limits Active"
            })
            .setContentText("Helping you stay focused...")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .build()
            
        startForeground(NOTIFICATION_ID, notification)
        
        if (runnable == null) {
            startLoop()
        }
        
        return START_STICKY
    }

    private fun startLoop() {
        handler = Handler(Looper.getMainLooper())
        runnable = object : Runnable {
            override fun run() {
                if (isBlockedAppInForeground()) {
                    showOverlay()
                } else {
                    hideOverlay()
                }
                handler?.postDelayed(this, 150) // Aggressive check
            }
        }
        handler?.post(runnable!!)
    }

    private fun isBlockedAppInForeground(): Boolean {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val endTime = System.currentTimeMillis()
        if (lastCheckTime == 0L) {
            lastCheckTime = endTime - 1000 * 60 * 60 // 1 hour ago
        }
        val beginTime = lastCheckTime

        val usageEvents = usageStatsManager.queryEvents(beginTime, endTime)
        val event = UsageEvents.Event()
        
        while (usageEvents.hasNextEvent()) {
            usageEvents.getNextEvent(event)
            if (event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) {
                lastForegroundPackage = event.packageName
            } else if (event.eventType == UsageEvents.Event.MOVE_TO_BACKGROUND) {
                if (event.packageName == lastForegroundPackage) {
                    lastForegroundPackage = null
                }
            }
        }
        
        lastCheckTime = endTime
        
        val fPackage = lastForegroundPackage ?: return false
        if (blockedPackages.contains(fPackage)) return true
        
        if (limitPackages.containsKey(fPackage)) {
            if (overLimitPackages.contains(fPackage)) {
                return true
            }

            val now = System.currentTimeMillis()
            if (now - lastUsageCheckTime > 5000) { // Check limits every 5 seconds
                lastUsageCheckTime = now
                val limitSecs = limitPackages[fPackage]!!
                val calendar = java.util.Calendar.getInstance()
                calendar.set(java.util.Calendar.HOUR_OF_DAY, 0)
                calendar.set(java.util.Calendar.MINUTE, 0)
                calendar.set(java.util.Calendar.SECOND, 0)
                calendar.set(java.util.Calendar.MILLISECOND, 0)
                
                val statsMap = usageStatsManager.queryAndAggregateUsageStats(calendar.timeInMillis, now)
                val stat = statsMap[fPackage]
                val usedSecs = if (stat != null) (stat.totalTimeInForeground / 1000).toInt() else 0

                if (usedSecs >= limitSecs) {
                    overLimitPackages.add(fPackage)
                    return true
                }
            }
        }
        
        return false
    }

    private fun showOverlay() {
        if (!isOverlayDisplayed) {
            val params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.MATCH_PARENT,
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY else WindowManager.LayoutParams.TYPE_PHONE,
                0, // Removed NOT_FOCUSABLE to allow button clicks
                PixelFormat.TRANSLUCENT
            )
            params.gravity = Gravity.CENTER
            try {
                windowManager?.addView(overlayView, params)
                isOverlayDisplayed = true
            } catch (e: Exception) {}
        }
    }

    private fun hideOverlay() {
        if (isOverlayDisplayed) {
            try {
                windowManager?.removeView(overlayView)
                isOverlayDisplayed = false
            } catch (e: Exception) {}
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        isRunning = false
        handler?.removeCallbacks(runnable!!)
        hideOverlay()
    }
}
