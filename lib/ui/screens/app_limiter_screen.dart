import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import '../../core/theme.dart';
import '../../features/app_limiter/app_limits_provider.dart';
import '../../features/app_limiter/app_usage_provider.dart';
import '../../features/app_limiter/app_limiter_service.dart';

class AppLimiterScreen extends ConsumerStatefulWidget {
  const AppLimiterScreen({super.key});

  @override
  ConsumerState<AppLimiterScreen> createState() => _AppLimiterScreenState();
}

class _AppLimiterScreenState extends ConsumerState<AppLimiterScreen> {
  List<AppInfo> _apps = [];
  List<AppInfo> _filteredApps = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _loadApps();
    _loadUsageStats();
  }

  Future<void> _requestPermission() async {
    await AppLimiterService.requestUsagePermission(context);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadApps() async {
    try {
      final List<AppInfo> apps = await InstalledApps.getInstalledApps(false, true);
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

  Future<void> _loadUsageStats() async {
    await ref.read(appUsageProvider.notifier).loadUsageStats();
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

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  Future<void> _showLimitDialog(AppInfo appInfo) async {
    final limits = ref.read(appLimitsProvider);
    final existingLimit = limits.where((l) => l.packageName == appInfo.packageName).firstOrNull;
    
    int hours = existingLimit?.dailyLimit.inHours ?? 0;
    int minutes = existingLimit?.dailyLimit.inMinutes.remainder(60) ?? 30;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text(
          'Set Daily Limit for ${appInfo.name}',
          style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: hours,
                    decoration: const InputDecoration(labelText: 'Hours'),
                    items: List.generate(24, (i) => DropdownMenuItem(value: i, child: Text('$i'))),
                    onChanged: (val) => hours = val ?? 0,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: minutes,
                    decoration: const InputDecoration(labelText: 'Minutes'),
                    items: List.generate(60, (i) => DropdownMenuItem(value: i, child: Text('$i'))),
                    onChanged: (val) => minutes = val ?? 0,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          FilledButton(
            onPressed: () {
              final limit = Duration(hours: hours, minutes: minutes);
              final appLimit = existingLimit?.copyWith(
                dailyLimitSeconds: limit.inSeconds,
                isEnabled: true,
              ) ?? AppLimit(
                packageName: appInfo.packageName ?? '',
                appName: appInfo.name ?? 'Unknown',
                dailyLimitSeconds: limit.inSeconds,
                usedTodaySeconds: 0,
                isEnabled: true,
              );
              ref.read(appLimitsProvider.notifier).addOrUpdateLimit(appLimit);
              AppLimiterService.setAppLimit(appInfo.packageName ?? '', limit);
              Navigator.pop(context);
            },
            child: const Text('Set Limit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final limits = ref.watch(appLimitsProvider);
    final usageStats = ref.watch(appUsageProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('App Limits', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
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
                'Monitor and limit your app usage to stay focused.',
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
                        : RefreshIndicator(
                            onRefresh: _loadUsageStats,
                            child: ListView.separated(
                              itemCount: _filteredApps.length,
                              separatorBuilder: (context, index) => const Divider(color: AppColors.border, height: 1),
                              itemBuilder: (context, index) {
                                final appInfo = _filteredApps[index];
                                final appName = appInfo.name ?? 'Unknown App';
                                final packageName = appInfo.packageName ?? '';
                                final limit = limits.where((l) => l.packageName == packageName).firstOrNull;
                                final usage = usageStats.where((u) => u['packageName'] == packageName).firstOrNull;
                                final usedDuration = usage != null ? Duration(milliseconds: usage['totalTimeInForeground'] ?? 0) : Duration.zero;

                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
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
                                  title: Text(
                                    appName,
                                    style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Used today: ${_formatDuration(usedDuration)}',
                                        style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                                      ),
                                      if (limit != null && limit.isEnabled)
                                        Text(
                                          'Limit: ${_formatDuration(limit.dailyLimit)}',
                                          style: GoogleFonts.inter(color: AppColors.primary, fontSize: 12),
                                        ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      limit != null && limit.isEnabled ? Icons.edit : Icons.add,
                                      color: AppColors.primary,
                                    ),
                                    onPressed: () => _showLimitDialog(appInfo),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}