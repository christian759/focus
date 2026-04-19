import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../features/focus/focus_provider.dart';
import '../../features/focus/session_history_provider.dart';
import '../../features/streak/streak_provider.dart';
import '../../features/dnd/dnd_service.dart';
import '../../models/session.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../widgets/premium_background.dart';
import 'main_layout_screen.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {

  @override
  void initState() {
    super.initState();
    _handleSessionCompletion();
  }

  Future<void> _handleSessionCompletion() async {
    _autoSaveSession();
  }

  void _autoSaveSession() {
    final focusState = ref.read(focusProvider);
    final isSuccess = focusState.status == FocusStatus.success;

    final session = SessionModel(
      id: focusState.sessionId ?? '',
      startTime: focusState.startTime ?? DateTime.now(),
      endTime: DateTime.now(),
      durationSeconds: focusState.totalSeconds - focusState.remainingSeconds,
      status: isSuccess ? SessionStatus.completed : SessionStatus.partial,
      outputText: '', // Removed thought/manual text input
    );

    ref.read(sessionHistoryProvider.notifier).addSession(session);
    
    if (isSuccess) {
      ref.read(streakProvider.notifier).updateStreak();
    }
  }

  void _finish() {
    ref.read(focusProvider.notifier).reset();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainLayoutScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final focusState = ref.watch(focusProvider);
    final isSuccess = focusState.status == FocusStatus.success;
    final totalMinutes = (focusState.totalSeconds - focusState.remainingSeconds) ~/ 60;

    return Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                const Spacer(flex: 1),
                Icon(
                  isSuccess ? Icons.auto_awesome : Icons.self_improvement_rounded,
                  color: AppColors.primary,
                  size: 80,
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut)
                 .then().shimmer(duration: 1.seconds),
                
                const SizedBox(height: 24),
                
                Text(
                  isSuccess ? 'Growth achieved' : 'Session complete',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 300.ms),
                
                const SizedBox(height: 12),
                
                Text(
                  isSuccess
                      ? 'Your dedication is paying off.'
                      : 'You focused for $totalMinutes minutes. Every step counts.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 14),
                ).animate().fadeIn(delay: 500.ms),
                
                const SizedBox(height: 32),

                // Session time badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${totalMinutes}m session',
                        style: GoogleFonts.inter(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms).scale(),

                const Spacer(flex: 1),
 
                 const Spacer(flex: 1),
                
                const SizedBox(height: 40),
                
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _finish,
                    child: const Text('Continue'),
                  ),
                ).animate().fadeIn(delay: 700.ms),
                const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
