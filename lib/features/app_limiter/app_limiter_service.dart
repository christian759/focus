import 'package:app_limiter/app_limiter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class AppLimiterService {
  static final AppLimiter _plugin = AppLimiter();
  static const MethodChannel _channel = MethodChannel('com.ceo3.focus/usage');

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
        final List<dynamic> result = await _channel.invokeMethod('getUsageStats');
        return result.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (e) {
        debugPrint('Failed to get usage stats: $e');
        return [];
      }
    }
    return [];
  }
}