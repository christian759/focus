import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../features/dnd/block_apps_provider.dart';

class BlockAppsScreen extends ConsumerWidget {
  const BlockAppsScreen({super.key});

  static const List<Map<String, String>> socialApps = [
    {'name': 'Instagram', 'icon': 'assets/icon.png'}, // Placeholder using existing asset if needed
    {'name': 'TikTok', 'icon': 'assets/icon.png'},
    {'name': 'Facebook', 'icon': 'assets/icon.png'},
    {'name': 'Twitter / X', 'icon': 'assets/icon.png'},
    {'name': 'Snapchat', 'icon': 'assets/icon.png'},
    {'name': 'WhatsApp', 'icon': 'assets/icon.png'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockedApps = ref.watch(blockAppsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Block Apps', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select the apps you want to block during your focus sessions.\n(Note: Native interception assumes permissions are granted)',
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: socialApps.length,
                  separatorBuilder: (context, index) => Divider(color: AppColors.border),
                  itemBuilder: (context, index) {
                    final appInfo = socialApps[index];
                    final appName = appInfo['name']!;
                    final isBlocked = blockedApps.contains(appName);

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.apps_rounded, color: AppColors.primary),
                      ),
                      title: Text(appName, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
                      trailing: Switch(
                        value: isBlocked,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          ref.read(blockAppsProvider.notifier).toggleApp(appName);
                        },
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
