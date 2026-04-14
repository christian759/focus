import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../widgets/premium_background.dart';

class InitializingScreen extends StatelessWidget {
  const InitializingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PremiumBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                ),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                  backgroundColor: Colors.white.withOpacity(0.05),
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
              const SizedBox(height: 32),
              Text(
                'Focus+',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 8),
              Text(
                'PREPARING YOUR SPACE',
                style: GoogleFonts.inter(
                  color: Colors.white24,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
