import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dnd_service.dart';
import 'block_apps_provider.dart';

class PassiveBlockingState {
  final bool isActive;
  final DateTime? activeSince;
  final int todayPassiveMinutes; // accumulated passive blocking minutes today

  PassiveBlockingState({
    this.isActive = false,
    this.activeSince,
    this.todayPassiveMinutes = 0,
  });

  PassiveBlockingState copyWith({
    bool? isActive,
    DateTime? activeSince,
    int? todayPassiveMinutes,
  }) {
    return PassiveBlockingState(
      isActive: isActive ?? this.isActive,
      activeSince: isActive == false ? null : (activeSince ?? this.activeSince),
      todayPassiveMinutes: todayPassiveMinutes ?? this.todayPassiveMinutes,
    );
  }
}

class PassiveBlockingNotifier extends StateNotifier<PassiveBlockingState> {
  final Ref _ref;
  Timer? _trackingTimer;

  PassiveBlockingNotifier(this._ref) : super(PassiveBlockingState()) {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final isActive = prefs.getBool('passive_blocking_active') ?? false;
    final storedDate = prefs.getString('passive_blocking_date') ?? '';
    final todayStr = _todayKey();
    
    int todayMinutes = 0;
    if (storedDate == todayStr) {
      todayMinutes = prefs.getInt('passive_blocking_minutes') ?? 0;
    }

    state = PassiveBlockingState(
      isActive: isActive,
      activeSince: isActive ? DateTime.now() : null,
      todayPassiveMinutes: todayMinutes,
    );

    if (isActive) {
      _startTracking();
      // Re-enforce blocking on reload
      final blockedApps = _ref.read(blockAppsProvider);
      DndService.turnOnDnd(blockedApps);
    }
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  Future<void> togglePassiveBlocking() async {
    if (state.isActive) {
      await _deactivate();
    } else {
      await _activate();
    }
  }

  Future<void> _activate() async {
    final blockedApps = _ref.read(blockAppsProvider);
    await DndService.turnOnDnd(blockedApps);

    state = state.copyWith(
      isActive: true,
      activeSince: DateTime.now(),
    );
    _startTracking();
    await _saveState();
  }

  Future<void> _deactivate() async {
    _stopTracking();
    // Flush any remaining time
    _flushAccumulated();
    await DndService.turnOffDnd();

    state = state.copyWith(isActive: false);
    await _saveState();
  }

  void _startTracking() {
    _trackingTimer?.cancel();
    _trackingTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      state = state.copyWith(
        todayPassiveMinutes: state.todayPassiveMinutes + 1,
      );
      _saveMinutes();
    });
  }

  void _stopTracking() {
    _trackingTimer?.cancel();
    _trackingTimer = null;
  }

  void _flushAccumulated() {
    if (state.activeSince != null) {
      final elapsed = DateTime.now().difference(state.activeSince!).inMinutes;
      if (elapsed > 0) {
        state = state.copyWith(
          todayPassiveMinutes: state.todayPassiveMinutes + elapsed,
        );
        _saveMinutes();
      }
    }
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('passive_blocking_active', state.isActive);
  }

  Future<void> _saveMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('passive_blocking_date', _todayKey());
    await prefs.setInt('passive_blocking_minutes', state.todayPassiveMinutes);
  }

  int getTodayPassiveMinutes() {
    return state.todayPassiveMinutes;
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    super.dispose();
  }
}

final passiveBlockingProvider =
    StateNotifierProvider<PassiveBlockingNotifier, PassiveBlockingState>((ref) {
  return PassiveBlockingNotifier(ref);
});
