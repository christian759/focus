import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../features/user/user_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Welcome to Focus+',
      description: 'Your premium workspace for deep work and undisturbed productivity.',
      icon: Icons.auto_awesome_rounded,
    ),
    OnboardingData(
      title: 'Deep Focus mode',
      description: 'Our strict native blocking protocol keeps distracting apps out of your way.',
      icon: Icons.security_rounded,
    ),
    OnboardingData(
      title: 'Visualize Growth',
      description: 'Detailed analytics and daily goals to track your journey toward mastery.',
      icon: Icons.analytics_rounded,
    ),
    OnboardingData(
      title: 'Almost Ready',
      description: 'What should we call you? Your journey starts as soon as you give us a name.',
      icon: Icons.person_add_alt_1_rounded,
      isLast: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(0.05),
                          ),
                          child: Icon(page.icon, size: 80, color: AppColors.primary),
                        ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 60),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
                        if (page.isLast) ...[
                          const SizedBox(height: 48),
                          TextField(
                            controller: _nameController,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 18),
                            decoration: InputDecoration(
                              hintText: 'Enter your name',
                              hintStyle: const TextStyle(color: Colors.white24),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.03),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 20),
                            ),
                          ).animate().fadeIn(delay: 800.ms),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
            ),
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page Indicators
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? AppColors.primary : Colors.white12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  
                  // Next/Start Button
                  FloatingActionButton.extended(
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOutCubic,
                        );
                      } else {
                        _finishOnboarding();
                      }
                    },
                    backgroundColor: AppColors.primary,
                    label: Text(_currentPage == _pages.length - 1 ? 'GET STARTED' : 'NEXT'),
                    icon: Icon(_currentPage == _pages.length - 1 ? Icons.check : Icons.arrow_forward),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _finishOnboarding() {
    final name = _nameController.text.trim();
    if (name.isEmpty && _currentPage == _pages.length - 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a name to continue'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    ref.read(userProvider.notifier).setName(name);
    ref.read(userProvider.notifier).completeOnboarding();
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final bool isLast;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    this.isLast = false,
  });
}
