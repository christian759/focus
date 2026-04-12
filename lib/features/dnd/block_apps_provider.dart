import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final blockAppsProvider = StateNotifierProvider<BlockAppsNotifier, List<String>>((ref) {
  return BlockAppsNotifier();
});

class BlockAppsNotifier extends StateNotifier<List<String>> {
  BlockAppsNotifier() : super([]) {
    _loadBlockedApps();
  }

  static const String _key = 'blocked_social_apps';

  Future<void> _loadBlockedApps() async {
    final prefs = await SharedPreferences.getInstance();
    final apps = prefs.getStringList(_key) ?? ['Instagram', 'TikTok']; // Default values
    state = apps;
  }

  Future<void> toggleApp(String appName) async {
    List<String> current = List.from(state);
    if (current.contains(appName)) {
      current.remove(appName);
    } else {
      current.add(appName);
    }
    state = current;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, current);
  }
}
