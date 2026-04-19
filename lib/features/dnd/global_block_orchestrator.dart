import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dnd_service.dart';
import '../../features/focus/focus_provider.dart';
import '../../features/dnd/passive_blocking_provider.dart';
import '../../features/app_limiter/app_limits_provider.dart';
import '../../features/dnd/block_apps_provider.dart';

final globalBlockOrchestratorProvider = Provider<void>((ref) {
  final focusState = ref.watch(focusProvider);
  final passiveState = ref.watch(passiveBlockingProvider);
  final limits = ref.watch(appLimitsProvider);
  final blockedApps = ref.watch(blockAppsProvider);

  final isFocusActive = focusState.status == FocusStatus.running;
  final isPassiveActive = passiveState.isActive;
  
  final activeLimits = limits.where((l) => l.isEnabled && l.dailyLimit.inSeconds > 0).toList();
  final hasLimits = activeLimits.isNotEmpty;

  if (isFocusActive || isPassiveActive || hasLimits) {
    debugPrint('Orchestrator: Active state detected. Starting StrictlyBlockService.');
    
    // Determine mode
    final String mode;
    if (isFocusActive) {
      mode = 'deep';
    } else if (isPassiveActive) {
      mode = 'passive';
    } else {
      mode = 'limits';
    }
    
    // Only block the static "blockedApps" black list if deep focus or passive shielding is ON.
    // If only limits are configured, don't strictly block all social apps.
    final packagesToBlock = (isFocusActive || isPassiveActive) ? blockedApps : <String>[];
    
    final limitsMap = {
      for (var l in activeLimits)
        l.packageName: l.dailyLimit.inSeconds
    };
    
    DndService.turnOnDnd(packagesToBlock, mode: mode, limitPackages: limitsMap);
  } else {
    debugPrint('Orchestrator: No active states. Stopping StrictlyBlockService.');
    DndService.turnOffDnd();
  }
});
