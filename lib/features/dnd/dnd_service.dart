import 'package:flutter/material.dart';
import 'package:app_limiter/app_limiter.dart';
import 'dart:io';

class DndService {
  static Future<bool> requestDndPermission(BuildContext context) async {
    if (Platform.isAndroid) {
      try {
        final plugin = AppLimiterPlugin();
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
        final plugin = AppLimiterPlugin();
        // The API signature requires passing the blocked packages or relying on state
        // Depending on specific plugin usage:
        // await plugin.blockAndroidApps(packageList); 
      } catch (e) {
        debugPrint('Failed to block apps: \$e');
      }
    }
  }

  static Future<void> turnOffDnd() async {
    if (Platform.isAndroid) {
      try {
        final plugin = AppLimiterPlugin();
        // await plugin.unBlockAndroidApps();
      } catch (e) {
        debugPrint('Failed to unblock apps: \$e');
      }
    }
  }
}
