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
    await DndService.turnOffDnd();
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
      status: isSuccess ? SessionStatus.success : SessionStatus.fail,
      outputText: '', // Removed thought/manual text input
    );

    ref.read(sessionHistoryProvider.notifier).addSession(session);
    
    if (isSuccess) {
      ref.read(streakProvider.notifier).updateStreak();
    }
  }

  void _finish() {
    ref.read(focusProvider.notifier).reset();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final focusState = ref.watch(focusProvider);
    final isSuccess = focusState.status == FocusStatus.success;
    final accentColor = isSuccess ? AppColors.primary : AppColors.error;

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
                  isSuccess ? Icons.auto_awesome : Icons.error_outline_rounded,
                  color: accentColor,
                  size: 80,
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut)
                 .then().shimmer(duration: 1.seconds),
                
                const SizedBox(height: 24),
                
                Text(
                  isSuccess ? 'Growth achieved' : 'Session interrupted',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 300.ms),
                
                const SizedBox(height: 12),
                
                Text(
                  isSuccess ? 'Your dedication is paying off.' : 'Every step counts. Reset and flow again.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 14),
                ).animate().fadeIn(delay: 500.ms),
                
                const Spacer(flex: 1),
  
                 const Spacer(flex: 1),
                
                const SizedBox(height: 40),
                
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _finish,
                    style: FilledButton.styleFrom(
                      backgroundColor: isSuccess ? Colors.white : AppColors.error.withOpacity(0.1),
                      foregroundColor: isSuccess ? Colors.black : AppColors.error,
                    ),
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
