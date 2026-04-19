import 'package:flutter/material.dart';
import 'package:app_limiter/app_limiter.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class DndService {
  static const _channel = MethodChannel('com.ceo3.focus/blocking');

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

  static Future<void> turnOnDnd(List<String> blockedPackages, {String mode = 'deep', Map<String, int>? limitPackages}) async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('startStrictBlock', {
          'packages': blockedPackages,
          'mode': mode,
          if (limitPackages != null) 'limitPackages': limitPackages.keys.toList(),
          if (limitPackages != null) 'limitSeconds': limitPackages.values.toList(),
        });
      } catch (e) {
        debugPrint('Failed to block apps: $e');
      }
    }
  }

  static Future<void> turnOffDnd() async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('stopStrictBlock');
      } catch (e) {
        debugPrint('Failed to unblock apps: $e');
      }
    }
  }
}
