import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../models/app_limit.dart';

final appLimitsProvider = StateNotifierProvider<AppLimitsNotifier, List<AppLimit>>((ref) {
  return AppLimitsNotifier();
});

class AppLimitsNotifier extends StateNotifier<List<AppLimit>> {
  AppLimitsNotifier() : super([]) {
    _loadLimits();
  }

  static const String _boxName = 'app_limits';

  Future<void> _loadLimits() async {
    final box = await Hive.openBox<AppLimit>(_boxName);
    state = box.values.toList();
  }

  Future<void> addOrUpdateLimit(AppLimit limit) async {
    final box = await Hive.openBox<AppLimit>(_boxName);
    final existingIndex = state.indexWhere((l) => l.packageName == limit.packageName);
    
    if (existingIndex != -1) {
      // Update existing
      final updated = limit;
      state = [...state]..[existingIndex] = updated;
      await box.put(limit.packageName, updated);
    } else {
      // Add new
      state = [...state, limit];
      await box.put(limit.packageName, limit);
    }
  }

  Future<void> removeLimit(String packageName) async {
    final box = await Hive.openBox<AppLimit>(_boxName);
    state = state.where((l) => l.packageName != packageName).toList();
    await box.delete(packageName);
  }

  Future<void> updateUsage(String packageName, Duration used) async {
    final box = await Hive.openBox<AppLimit>(_boxName);
    final existingIndex = state.indexWhere((l) => l.packageName == packageName);
    if (existingIndex != -1) {
      final updated = state[existingIndex].copyWith(usedTodaySeconds: used.inSeconds);
      state = [...state]..[existingIndex] = updated;
      await box.put(packageName, updated);
    }
  }

  // Reset daily usage (call at midnight or app start)
  Future<void> resetDailyUsage() async {
    final box = await Hive.openBox<AppLimit>(_boxName);
    final updated = state.map((limit) => limit.copyWith(usedTodaySeconds: 0)).toList();
    state = updated;
    for (final limit in updated) {
      await box.put(limit.packageName, limit);
    }
  }
}