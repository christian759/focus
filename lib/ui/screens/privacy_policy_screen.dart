import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Privacy Policy', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Privacy Matters',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              _buildSection(
                'Data Collection',
                'Focus+ collected minimal data to provide its services. We do not sell your personal data. All app usage statistics are processed locally on your device.',
              ),
              _buildSection(
                'Blocking Logic',
                'To help you stay focused, this app requires usage access and overlay permissions. This data is used solely to identify when restricted apps are opened and to display the focus overlay.',
              ),
              _buildSection(
                'Third Party Services',
                'We may use aggregate, non-identifiable data to improve app performance and stability. No personal usage patterns are shared with third parties.',
              ),
              _buildSection(
                'Your Rights',
                'You have the right to access, modify, or delete any data the app may have stored. Since most data is local, clearing app cache or uninstalling will remove this data.',
              ),
              const SizedBox(height: 40),
              Center(
                child: Text(
                  'Last updated: April 2026',
                  style: GoogleFonts.inter(color: Colors.white24, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
