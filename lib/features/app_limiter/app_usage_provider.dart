import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_limiter_service.dart';

final appUsageProvider = StateNotifierProvider<AppUsageNotifier, List<Map<String, dynamic>>>((ref) {
  return AppUsageNotifier();
});

class AppUsageNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  AppUsageNotifier() : super([]);

  Future<void> loadUsageStats() async {
    final stats = await AppLimiterService.getAppUsageStats();
    state = stats;
  }

  Future<void> refresh() async {
    await loadUsageStats();
  }
}