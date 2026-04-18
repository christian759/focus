import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import 'block_apps_screen.dart';
import 'about_screen.dart';
import 'app_limiter_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            _buildSettingsItem(
              context, 
              icon: Icons.block_flipped, 
              title: 'Block Apps', 
              subtitle: 'Manage distracting social media apps',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BlockAppsScreen())),
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              context, 
              icon: Icons.timer, 
              title: 'App Limits', 
              subtitle: 'Set daily usage limits for apps',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppLimiterScreen())),
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              context, 
              icon: Icons.info_outline_rounded, 
              title: 'About', 
              subtitle: 'App version and developer info',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
            ),

            const SizedBox(height: 16),
            _buildSettingsItem(
              context, 
              icon: Icons.alternate_email_rounded, 
              title: 'Contact Support', 
              subtitle: 'Get help or report a bug',
              onTap: () => _showContactDialog(context),
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              context, 
              icon: Icons.shield_outlined, 
              title: 'Privacy Policy', 
              subtitle: 'How we handle your data',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening privacy policy...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: AppColors.border)),
        title: Text('Contact Us', style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Found a bug or have a suggestion?\n\nContact us at:\nsupport@focusplus.app', style: GoogleFonts.inter(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white54)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _launchURL('https://forms.gle/focus-plus-support');
            },
            child: const Text('Open Help Center'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  Widget _buildSettingsItem(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap, Color? iconColor}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor ?? Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: GoogleFonts.inter(color: Colors.white60, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}
