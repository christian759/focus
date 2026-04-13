import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../features/streak/streak_provider.dart';
import '../../features/focus/session_history_provider.dart';
import 'package:intl/intl.dart';

class StreakScreen extends ConsumerWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider);
    final sessions = ref.watch(sessionHistoryProvider);
    
    // Calculate 30-day activity map
    final now = DateTime.now();
    final last30Days = List.generate(30, (i) => DateTime(now.year, now.month, now.day).subtract(Duration(days: 29 - i)));
    
    final activeDates = sessions.map((s) => DateTime(s.startTime.year, s.startTime.month, s.startTime.day)).toSet();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('STREAK', style: GoogleFonts.inter(letterSpacing: 4, fontWeight: FontWeight.bold, fontSize: 14)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // The Flame
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 100,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.local_fire_department_rounded, size: 120, color: AppColors.primary)
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 2.seconds, curve: Curves.easeInOut),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              '${streak.currentStreak}',
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'DAY STREAK',
              style: GoogleFonts.inter(
                color: AppColors.primary,
                fontSize: 14,
                letterSpacing: 4,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 60),
            
            // 30-Day Grid
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LAST 30 DAYS',
                    style: GoogleFonts.inter(color: Colors.white38, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: 30,
                    itemBuilder: (context, index) {
                      final day = last30Days[index];
                      final isActive = activeDates.contains(day);
                      final isToday = DateUtils.isSameDay(day, now);
                      
                      return Container(
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(8),
                          border: isToday ? Border.all(color: AppColors.primary, width: 2) : null,
                          boxShadow: isActive ? [
                            BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8)
                          ] : [],
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: GoogleFonts.inter(
                              color: isActive ? Colors.black : Colors.white24,
                              fontSize: 10,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: (index * 20).ms).scale();
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            // Consistency Card
            _buildStatCard(
              'TOTAL SESSIONS', 
              '${sessions.length}', 
              Icons.bolt_rounded,
            ),
            const SizedBox(height: 16),
             _buildStatCard(
              'DAILY AVERAGE', 
              '${sessions.isEmpty ? 0 : (sessions.fold(0, (sum, s) => sum + (s.durationSeconds ~/ 60)) / 30).toStringAsFixed(1)} MINS', 
              Icons.trending_up_rounded,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white24, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.inter(color: Colors.white24, fontSize: 10, letterSpacing: 1)),
              Text(value, style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
