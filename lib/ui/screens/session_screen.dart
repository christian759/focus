import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../features/focus/focus_provider.dart';
import '../../features/dnd/dnd_service.dart';
import 'result_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../widgets/premium_background.dart';

class SessionScreen extends ConsumerWidget {
  const SessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusState = ref.watch(focusProvider);

    if (focusState.status == FocusStatus.success || focusState.status == FocusStatus.failed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ResultScreen()),
        );
      });
    }

    final minutes = (focusState.remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (focusState.remainingSeconds % 60).toString().padLeft(2, '0');

    return WillPopScope(
      onWillPop: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: AppColors.border)),
            title: Text('Quit session?', style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold)),
            content: Text('Focus will be lost. Are you sure?', style: GoogleFonts.inter(color: Colors.white70)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Stay focused')),
              TextButton(
                onPressed: () async {
                  await DndService.turnOffDnd();
                  ref.read(focusProvider.notifier).failSession();
                  if (context.mounted) Navigator.pop(context, true);
                },
                child: const Text('Quit', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
        return confirmed ?? false;
      },
      child: Scaffold(
        body: PremiumBackground(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                const Spacer(flex: 2),
                Text(
                  'Current focus',
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 13, letterSpacing: 2),
                ).animate().fadeIn(),
                const SizedBox(height: 8),
                Text(
                  'Reading session',
                  style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ).animate().fadeIn(delay: 200.ms),
                
                const Spacer(flex: 3),
                
                // Minimalist Timer
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 240,
                        height: 240,
                        child: CircularProgressIndicator(
                          value: focusState.totalSeconds > 0 ? focusState.remainingSeconds / focusState.totalSeconds : 0,
                          color: AppColors.primary,
                          backgroundColor: Colors.white.withOpacity(0.03),
                          strokeWidth: 2,
                          strokeCap: StrokeCap.round,
                        ),
                      ).animate(onPlay: (c) => c.repeat(reverse: true))
                       .scale(begin: const Offset(1,1), end: const Offset(1.05, 1.05), duration: 4.seconds),
                      
                      Text(
                        '$minutes:$seconds',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 64,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn(delay: 400.ms),
                    ],
                  ),
                ),
                
                const Spacer(flex: 5),
                
                IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white60, size: 28),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.05),
                    padding: const EdgeInsets.all(20),
                    shape: const CircleBorder(),
                  ),
                ).animate().fadeIn(delay: 1.seconds),
                const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
