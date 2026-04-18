import 'package:app_limiter/app_limiter.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class AppLimiterService {
  static final AppLimiter _plugin = AppLimiter();

  static Future<bool> requestUsagePermission(BuildContext context) async {
    if (Platform.isAndroid) {
      try {
        await _plugin.requestAndroidPermission();
        return true;
      } catch (e) {
        return false;
      }
    }
    return true;
  }

  static Future<List<Map<String, dynamic>>> getAppUsageStats() async {
    if (Platform.isAndroid) {
      try {
        return await _plugin.getUsageStats();
      } catch (e) {
        debugPrint('Failed to get usage stats: $e');
        return [];
      }
    }
    return [];
  }

  static Future<void> setAppLimit(String packageName, Duration limit) async {
    if (Platform.isAndroid) {
      try {
        await _plugin.setAppLimit(packageName, limit.inMinutes);
      } catch (e) {
        debugPrint('Failed to set app limit: $e');
      }
    }
  }

  static Future<void> removeAppLimit(String packageName) async {
    if (Platform.isAndroid) {
      try {
        await _plugin.removeAppLimit(packageName);
      } catch (e) {
        debugPrint('Failed to remove app limit: $e');
      }
    }
  }
}