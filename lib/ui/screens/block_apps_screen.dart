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
  List<AppInfo> _filteredApps = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadApps() async {
    try {
      // false includes system apps (like YouTube)
      final List<AppInfo> apps = await InstalledApps.getInstalledApps(false, true);
      // Sort alphabetically
      apps.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      setState(() {
        _apps = apps;
        _filteredApps = apps;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterApps(String query) {
    setState(() {
      _filteredApps = _apps
          .where((app) =>
              (app.name ?? '').toLowerCase().contains(query.toLowerCase()) ||
              (app.packageName ?? '').toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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
                'Select apps to block passively. System apps like YouTube are now included.',
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: _filterApps,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search apps...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.search, color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading 
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : _filteredApps.isEmpty
                        ? Center(child: Text("No apps found", style: GoogleFonts.inter(color: Colors.white)))
                        : ListView.separated(
                            itemCount: _filteredApps.length,
                            separatorBuilder: (context, index) => const Divider(color: AppColors.border, height: 1),
                            itemBuilder: (context, index) {
                              final appInfo = _filteredApps[index];
                              final appName = appInfo.name ?? 'Unknown App';
                              final packageName = appInfo.packageName ?? '';
                              final isBlocked = blockedApps.contains(packageName);

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 4),
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
                                title: Text(appName, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
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

