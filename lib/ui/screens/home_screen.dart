import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../features/focus/session_history_provider.dart';
import '../../features/streak/streak_provider.dart';
import '../../features/dnd/passive_blocking_provider.dart';
import '../../features/navigation/navigation_provider.dart';
import '../../features/focus/daily_goal_provider.dart';
import '../../features/dnd/block_apps_provider.dart';
import '../../features/focus/focus_provider.dart';

import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../features/user/user_provider.dart';
import '../../features/todo/todo_provider.dart';
import 'create_focus_screen.dart';
import 'streak_screen.dart';
import 'session_screen.dart';
import '../widgets/focus_gauge.dart';
import '../widgets/premium_background.dart';
import 'tasks_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final streak = ref.watch(streakProvider);
    final passiveState = ref.watch(passiveBlockingProvider);
    final blockedApps = ref.watch(blockAppsProvider);
    final dailyGoal = ref.watch(dailyGoalProvider);
    final userState = ref.watch(userProvider);
    final todos = ref.watch(todoProvider);
    final focusState = ref.watch(focusProvider);

    final isSessionRunning = focusState.status == FocusStatus.running;
    final todayTasks = todos.where((t) => !t.isCompleted).take(2).toList();
    final focusMinutes = ref.read(sessionHistoryProvider.notifier).getTodayFocusMinutes();
    final passiveMinutes = passiveState.todayPassiveMinutes;
    final totalMinutesToday = focusMinutes + passiveMinutes;

    return Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildHeader(userState.name, streak.currentStreak),
                      const SizedBox(height: 32),
                      _buildProductivityHub(totalMinutesToday, dailyGoal, streak.currentStreak),
                      const SizedBox(height: 32),
                      isSessionRunning 
                        ? _buildActiveFocusCard(focusState)
                        : _buildStartFocusCard(),
                      const SizedBox(height: 32),
                      if (todayTasks.isNotEmpty) ...[
                        _buildPrioritiesSection(todayTasks),
                        const SizedBox(height: 32),
                      ],
                      _buildPassiveBlockingCard(passiveState, blockedApps.isNotEmpty),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name, int streakCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, Colors.deepPurpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.background,
                child: Icon(Icons.person, color: Colors.white70, size: 24),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.5),
                ),
                Text(
                  name.isNotEmpty ? name : 'Focus Friend',
                  style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                ),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StreakScreen())),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department_rounded, color: AppColors.primary, size: 22),
                const SizedBox(width: 6),
                Text('$streakCount', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.1, end: 0);
  }

  Widget _buildProductivityHub(int current, int goal, int streak) {
    return GestureDetector(
      onTap: () => _showGoalDialog(context, goal),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.02)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 30, spreadRadius: -5),
          ],
        ),
        child: Row(
          children: [
            FocusGauge(currentMinutes: current, goalMinutes: goal, size: 84, showInfo: false),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DAILY PROGRESS',
                    style: GoogleFonts.inter(color: AppColors.primary.withOpacity(0.9), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$current / $goal mins',
                      style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amberAccent, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Great Job!',
                        style: GoogleFonts.inter(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
    );
  }

  Widget _buildActiveFocusCard(FocusState state) {
    final minutes = (state.remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (state.remainingSeconds % 60).toString().padLeft(2, '0');
    final progress = state.totalSeconds > 0 ? (state.totalSeconds - state.remainingSeconds) / state.totalSeconds : 0.0;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SessionScreen())),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary.withOpacity(0.2), AppColors.primary.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 20, spreadRadius: 0),
          ]
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: progress, strokeWidth: 5, color: AppColors.primary, backgroundColor: Colors.white.withOpacity(0.1), strokeCap: StrokeCap.round,
                  ),
                ),
                const Icon(Icons.timer_rounded, color: AppColors.primary, size: 24),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SESSION ACTIVE', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  const SizedBox(height: 4),
                  Text('Deep Work', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$minutes:$seconds', style: GoogleFonts.inter(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                Text('REMAINING', style: GoogleFonts.inter(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
              ],
            ),
          ],
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 2500.ms, color: AppColors.primary.withOpacity(0.2)),
    );
  }

  Widget _buildStartFocusCard() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateFocusScreen())),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.cardBackground.withOpacity(0.8),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 15)),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 15, spreadRadius: 2)
                ]
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1,1), end: const Offset(1.08, 1.08), duration: 2.seconds),
            const SizedBox(height: 20),
            Text('READY TO DIVE IN?', style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
            const SizedBox(height: 6),
            Text('Start a new deep work block', style: GoogleFonts.inter(color: Colors.white54, fontSize: 14)),
          ],
        ),
      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildPrioritiesSection(List<Todo> tasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('TODAY\'S MISSIONS', style: GoogleFonts.inter(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TasksScreen())),
              child: Text('VIEW ALL', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...tasks.map((task) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              const Icon(Icons.radio_button_unchecked, color: AppColors.primary, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(task.title, style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
              ),
              if (task.alarmTime != null)
                Text(task.alarmTime!, style: GoogleFonts.inter(color: Colors.white38, fontSize: 12)),
            ],
          ),
        )).toList(),
      ],
    ).animate().fadeIn(delay: 600.ms);
  }

  void _showGoalDialog(BuildContext context, int currentGoal) {
    int selectedGoal = currentGoal;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32), side: const BorderSide(color: AppColors.border)),
        title: Text('Daily Focus Goal', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Set a challenging but achievable target.', style: GoogleFonts.inter(color: Colors.white54, fontSize: 14)),
            const SizedBox(height: 32),
            StatefulBuilder(
              builder: (context, setModalState) {
                return Column(
                  children: [
                    Text('$selectedGoal MINS', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 36, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 16),
                    Slider(
                      value: selectedGoal.toDouble(), min: 30, max: 480, divisions: 15, activeColor: AppColors.primary,
                      onChanged: (val) => setModalState(() => selectedGoal = val.toInt()),
                    ),
                  ],
                );
              }
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          FilledButton(
            onPressed: () {
              ref.read(dailyGoalProvider.notifier).setGoal(selectedGoal);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Set Goal', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPassiveBlockingCard(PassiveBlockingState passiveState, bool appsSelected) {
    return GestureDetector(
      onTap: () {
        if (!appsSelected) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Please select apps in Settings first.')));
          return;
        }
        ref.read(passiveBlockingProvider.notifier).togglePassiveBlocking();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: passiveState.isActive ? AppColors.primary.withOpacity(0.08) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: passiveState.isActive ? AppColors.primary.withOpacity(0.4) : AppColors.border, width: 1.5),
          boxShadow: passiveState.isActive ? [BoxShadow(color: AppColors.primary.withOpacity(0.06), blurRadius: 24, spreadRadius: 4)] : [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: passiveState.isActive ? LinearGradient(colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)]) : null,
                color: passiveState.isActive ? null : Colors.white.withOpacity(0.05), 
                shape: BoxShape.circle
              ),
              child: Icon(passiveState.isActive ? Icons.shield_rounded : Icons.shield_outlined, color: passiveState.isActive ? Colors.white : Colors.white54, size: 26),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Passive Shield', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(passiveState.isActive ? 'Guarding focus • ${passiveState.todayPassiveMinutes}m today' : appsSelected ? 'Tap to activate background shield.' : 'Choose apps from settings.', style: GoogleFonts.inter(color: passiveState.isActive ? AppColors.primary.withOpacity(0.8) : Colors.white38, fontSize: 13)),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: passiveState.isActive
                  ? Container(key: const ValueKey('active'), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(24)), child: Text('ON', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)))
                  : Container(key: const ValueKey('inactive'), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(24)), child: Text('OFF', style: GoogleFonts.inter(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1))),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0);
  }
}
