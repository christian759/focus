import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';

final appListProvider = FutureProvider<List<AppInfo>>((ref) async {
  // Fetch apps without icons for speed
  final apps = await InstalledApps.getInstalledApps(false, false);
  apps.sort((a, b) => (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase()));
  return apps;
});

final appIconProvider = FutureProvider.family<Uint8List?, String>((ref, packageName) async {
  try {
    return await InstalledApps.getAppIcon(packageName);
  } catch (e) {
    return null;
  }
});
