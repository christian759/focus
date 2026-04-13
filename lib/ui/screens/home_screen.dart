import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../features/focus/focus_provider.dart';
import '../../features/focus/session_history_provider.dart';
import '../../features/streak/streak_provider.dart';

import '../../features/user/user_provider.dart';

import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../widgets/premium_background.dart';
import 'create_focus_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserName();
    });
  }

  void _checkUserName() {
    final userName = ref.read(userProvider);
    if (userName.isEmpty) {
      _showNameDialog();
    }
  }

  void _showNameDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: Text('Welcome!', style: GoogleFonts.playfairDisplay(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'What is your name?',
              hintStyle: TextStyle(color: Colors.white38),
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  ref.read(userProvider.notifier).setName(controller.text.trim());
                  Navigator.pop(context);
                }
              },
              child: const Text('Continue'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = ref.watch(userProvider);
    final streak = ref.watch(streakProvider);
    final sessions = ref.watch(sessionHistoryProvider);

    return Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.local_fire_department, color: AppColors.primary, size: 24),
                              const SizedBox(width: 4),
                              Text('${streak.currentStreak}', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            ],
                          ),
                        ],
                      ).animate().fadeIn().slideX(begin: -0.2),
                      const SizedBox(height: 40),
                      Text(
                        'Good morning,',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.normal,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        userName.isNotEmpty ? userName : 'Friend',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontSize: 40,
                        ),
                      ),
                      const SizedBox(height: 32),
                      

                    ],
                  ),
                ),
                
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Sessions', style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 100.0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final reversedSessions = sessions.reversed.toList();
                        final isLarge = index == 0;
                        final duration = (reversedSessions[index].durationSeconds ~/ 60).toString();
                        final title = reversedSessions[index].outputText.isEmpty ? 'Focus Session' : reversedSessions[index].outputText;
                        return _buildFocusCard(context, duration, title, isLarge: isLarge);
                      },
                      childCount: sessions.length > 4 ? 4 : sessions.length,
                    ),
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

  Widget _buildFocusCard(BuildContext context, String value, String title, {bool isLarge = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 48,
                  height: 1,
                  color: isLarge ? AppColors.primary : Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.north_east_rounded, size: 16, color: Colors.white),
              ),
            ],
          ),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).scale();
  }
}
