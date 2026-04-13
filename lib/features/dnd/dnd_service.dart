import 'package:flutter/material.dart';
import 'package:app_limiter/app_limiter.dart';
import 'dart:io';

class DndService {
  static Future<bool> requestDndPermission(BuildContext context) async {
    if (Platform.isAndroid) {
      try {
        final plugin = AppLimiter();
        await plugin.requestAndroidPermission();
        return true;
      } catch (e) {
        return false;
      }
    }
    return true;
  }

  static Future<void> turnOnDnd() async {
    if (Platform.isAndroid) {
      try {
        final plugin = AppLimiter();
        await plugin.blocAndroidApp();
      } catch (e) {
        debugPrint('Failed to block apps: \$e');
      }
    }
  }

  static Future<void> turnOffDnd() async {
    if (Platform.isAndroid) {
      try {
        final plugin = AppLimiter();
        await plugin.unblocAndroidApp();
      } catch (e) {
        debugPrint('Failed to unblock apps: \$e');
      }
    }
  }
}
