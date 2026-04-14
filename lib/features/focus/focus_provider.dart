import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/session.dart';
import '../../services/alarm_service.dart';
import 'package:uuid/uuid.dart';

enum FocusStatus { idle, running, success, failed }

class FocusState {
  final int remainingSeconds;
  final int totalSeconds;
  final FocusStatus status;
  final String? sessionId;
  final DateTime? startTime;

  FocusState({
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.status,
    this.sessionId,
    this.startTime,
  });

  FocusState copyWith({
    int? remainingSeconds,
    int? totalSeconds,
    FocusStatus? status,
    String? sessionId,
    DateTime? startTime,
  }) {
    return FocusState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      status: status ?? this.status,
      sessionId: sessionId ?? this.sessionId,
      startTime: startTime ?? this.startTime,
    );
  }
}

class FocusNotifier extends StateNotifier<FocusState> {
  FocusNotifier() : super(FocusState(remainingSeconds: 0, totalSeconds: 0, status: FocusStatus.idle));

  Timer? _timer;

  void startSession(int minutes) {
    if (_timer != null) return;

    final seconds = minutes * 60;
    state = state.copyWith(
      remainingSeconds: seconds,
      totalSeconds: seconds,
      status: FocusStatus.running,
      sessionId: const Uuid().v4(),
      startTime: DateTime.now(),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        completeSession();
      }
    });
  }

  void completeSession() {
    _timer?.cancel();
    _timer = null;
    final minutes = state.totalSeconds ~/ 60;
    AlarmService.showSessionCompleteNotification(minutes: minutes, isSuccess: true);
    state = state.copyWith(status: FocusStatus.success);
  }

  void endSessionEarly() {
    if (state.status != FocusStatus.running) return;
    
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(status: FocusStatus.failed); // Internally still 'failed' for state logic, but will be saved as 'partial'
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    state = FocusState(remainingSeconds: 0, totalSeconds: 0, status: FocusStatus.idle);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final focusProvider = StateNotifierProvider<FocusNotifier, FocusState>((ref) {
  return FocusNotifier();
});
