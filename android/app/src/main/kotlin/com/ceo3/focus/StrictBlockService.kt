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
        createOverlayView()
        createNotificationChannel()
    }

    private fun createOverlayView() {
        val root = FrameLayout(this)
        root.setBackgroundColor(Color.parseColor("#121212"))
        
        val textView = TextView(this)
        textView.text = "FOCUS MODE ACTIVE\n\nThis app is restricted."
        textView.setTextColor(Color.WHITE)
        textView.gravity = Gravity.CENTER
        textView.textSize = 24f
        
        val lp = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.WRAP_CONTENT,
            FrameLayout.LayoutParams.WRAP_CONTENT,
            Gravity.CENTER
        )
        root.addView(textView, lp)
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

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Focus Mode Active")
            .setContentText("Blocking restricted apps...")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .build()
            
        startForeground(NOTIFICATION_ID, notification)
        startLoop()
        
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
        val beginTime = endTime - 1000 * 5 

        val usageEvents = usageStatsManager.queryEvents(beginTime, endTime)
        var lastPackage: String? = null
        val event = UsageEvents.Event()
        
        while (usageEvents.hasNextEvent()) {
            usageEvents.getNextEvent(event)
            if (event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) {
                lastPackage = event.packageName
            }
        }
        
        return blockedPackages.contains(lastPackage)
    }

    private fun showOverlay() {
        if (!isOverlayDisplayed) {
            val params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.MATCH_PARENT,
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY else WindowManager.LayoutParams.TYPE_PHONE,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
                PixelFormat.TRANSLUCENT
            )
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
