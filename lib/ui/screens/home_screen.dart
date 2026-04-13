import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../features/focus/session_history_provider.dart';
import '../../features/streak/streak_provider.dart';
import '../../features/dnd/passive_blocking_provider.dart';
import '../../features/navigation/navigation_provider.dart';
import '../../features/focus/daily_goal_provider.dart';
import '../../features/dnd/block_apps_provider.dart';

import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import 'create_focus_screen.dart';
import 'streak_screen.dart';
import '../widgets/focus_gauge.dart';
import '../widgets/premium_background.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final streak = ref.watch(streakProvider);
    final passiveState = ref.watch(passiveBlockingProvider);
    final dailyGoal = ref.watch(dailyGoalProvider);

    // Combine focus session minutes + passive blocking minutes for today
    final focusMinutes = ref.read(sessionHistoryProvider.notifier).getTodayFocusMinutes();
    final passiveMinutes = passiveState.todayPassiveMinutes;
    final totalMinutesToday = focusMinutes + passiveMinutes;

    return Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'FOCUS+',
                        style: GoogleFonts.inter(
                          color: AppColors.primary,
                          fontSize: 12,
                          letterSpacing: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn(),
                      const SizedBox(height: 12),
                      
                      GestureDetector(
                        onTap: () => _showGoalDialog(context, dailyGoal),
                        child: FocusGauge(
                          currentMinutes: totalMinutesToday,
                          goalMinutes: dailyGoal,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StreakScreen())),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_fire_department, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${streak.currentStreak} DAY STREAK',
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 500.ms),
                      const SizedBox(height: 32),

                      // Passive Blocking Card
                      _buildPassiveBlockingCard(passiveState),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateFocusScreen()),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          label: Row(
            children: [
              const Icon(Icons.add, size: 20),
              const SizedBox(width: 8),
              Text('New focus', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            ],
          ),
        ).animate().scale(delay: 600.ms),
      ),
    );
  }

  void _showGoalDialog(BuildContext context, int currentGoal) {
    int selectedGoal = currentGoal;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: AppColors.border)),
        title: Text('Daily Focus Goal', style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('How many minutes would you like to focus today?', 
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 24),
            StatefulBuilder(
              builder: (context, setModalState) {
                return Column(
                  children: [
                    Text('$selectedGoal MINS', 
                      style: GoogleFonts.playfairDisplay(color: AppColors.primary, fontSize: 32, fontWeight: FontWeight.bold)),
                    Slider(
                      value: selectedGoal.toDouble(),
                      min: 30,
                      max: 480,
                      divisions: 15,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setModalState(() => selectedGoal = val.toInt());
                      },
                    ),
                  ],
                );
              }
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          FilledButton(
            onPressed: () {
              ref.read(dailyGoalProvider.notifier).setGoal(selectedGoal);
              Navigator.pop(context);
            },
            child: const Text('Set Goal'),
          ),
        ],
      ),
    );
  }

  Widget _buildPassiveBlockingCard(PassiveBlockingState passiveState) {
    return GestureDetector(
      onTap: () {
        final blockedApps = ref.read(blockAppsProvider);
        if (blockedApps.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please select apps to block in Settings first.', 
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.primary.withOpacity(0.9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              action: SnackBarAction(
                label: 'SETTINGS',
                textColor: Colors.black,
                onPressed: () => ref.read(navigationProvider.notifier).state = 3,
              ),
            ),
          );
          return;
        }
        ref.read(passiveBlockingProvider.notifier).togglePassiveBlocking();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: passiveState.isActive
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: passiveState.isActive
                ? AppColors.primary.withOpacity(0.4)
                : AppColors.border,
            width: 1,
          ),
          boxShadow: passiveState.isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: passiveState.isActive
                    ? AppColors.primary.withOpacity(0.15)
                    : Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                passiveState.isActive ? Icons.shield_rounded : Icons.shield_outlined,
                color: passiveState.isActive ? AppColors.primary : Colors.white54,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Passive Shield',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    passiveState.isActive
                        ? 'Blocking distractions • ${passiveState.todayPassiveMinutes}m today'
                        : 'Tap to block selected apps. Go to Settings to manage blocked apps.',
                    style: GoogleFonts.inter(
                      color: passiveState.isActive ? AppColors.primary.withOpacity(0.7) : Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: passiveState.isActive
                  ? Container(
                      key: const ValueKey('active'),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'ON',
                        style: GoogleFonts.inter(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    )
                  : Container(
                      key: const ValueKey('inactive'),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'OFF',
                        style: GoogleFonts.inter(
                          color: Colors.white38,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }
}
