import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import '../../core/theme.dart';
import '../../features/dnd/block_apps_provider.dart';

class BlockAppsScreen extends ConsumerStatefulWidget {
  const BlockAppsScreen({super.key});

  @override
  ConsumerState<BlockAppsScreen> createState() => _BlockAppsScreenState();
}

class _BlockAppsScreenState extends ConsumerState<BlockAppsScreen> {
  List<AppInfo> _apps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    try {
      final List<AppInfo> apps = await InstalledApps.getInstalledApps(true, true);
      setState(() {
        _apps = apps;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                'Select apps to block passively. These apps are blocked in the background — no focus session needed.',
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shield_rounded, color: AppColors.primary.withOpacity(0.7), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Passive Shield blocks selected apps in the background. Enable it from the home screen to start protecting your focus automatically.',
                        style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _isLoading 
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : _apps.isEmpty
                        ? Center(child: Text("No apps found", style: GoogleFonts.inter(color: Colors.white)))
                        : ListView.separated(
                            itemCount: _apps.length,
                            separatorBuilder: (context, index) => const Divider(color: AppColors.border),
                            itemBuilder: (context, index) {
                              final appInfo = _apps[index];
                              final appName = appInfo.name ?? 'Unknown App';
                              final packageName = appInfo.packageName ?? '';
                              final isBlocked = blockedApps.contains(packageName);

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardBackground,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: appInfo.icon != null
                                      ? Image.memory(appInfo.icon!, width: 40, height: 40)
                                      : const Icon(Icons.android, color: AppColors.primary),
                                ),
                                title: Text(appName, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
                                subtitle: Text(packageName, style: GoogleFonts.inter(color: Colors.white38, fontSize: 11)),
                                trailing: Switch(
                                  value: isBlocked,
                                  activeColor: AppColors.primary,
                                  onChanged: (val) {
                                    ref.read(blockAppsProvider.notifier).toggleApp(packageName);
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

