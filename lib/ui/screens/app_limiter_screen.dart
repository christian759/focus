import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:installed_apps/app_info.dart';
import '../../core/theme.dart';
import '../../features/app_limiter/app_limits_provider.dart';
import '../../features/app_limiter/app_usage_provider.dart';
import '../../features/app_limiter/app_limiter_service.dart';
import '../../features/app_list/app_list_provider.dart';
import '../../models/app_limit.dart';

class AppLimiterScreen extends ConsumerStatefulWidget {
  const AppLimiterScreen({super.key});

  @override
  ConsumerState<AppLimiterScreen> createState() => _AppLimiterScreenState();
}

class _AppLimiterScreenState extends ConsumerState<AppLimiterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _loadUsageStats();
  }

  Future<void> _requestPermission() async {
    await AppLimiterService.requestUsagePermission(context);
  }

  Future<void> _loadUsageStats() async {
    await ref.read(appUsageProvider.notifier).loadUsageStats();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          if (existingLimit != null)
            TextButton(
              onPressed: () {
                ref.read(appLimitsProvider.notifier).removeLimit(appInfo.packageName ?? '');
                Navigator.pop(context);
              },
              child: const Text('Remove', style: TextStyle(color: AppColors.error)),
            ),
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
    final appsAsync = ref.watch(appListProvider);

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
                onChanged: (val) => setState(() => _searchQuery = val),
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
                child: appsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  error: (err, stack) => Center(child: Text("Error loading apps", style: GoogleFonts.inter(color: Colors.white))),
                  data: (apps) {
                    // Create a copy of the list for sorting
                    final sortedApps = List<AppInfo>.from(apps);
                    
                    // Sort by usage time descending
                    sortedApps.sort((a, b) {
                      final usageA = usageStats.where((u) => u['packageName'] == a.packageName).firstOrNull;
                      final usageB = usageStats.where((u) => u['packageName'] == b.packageName).firstOrNull;
                      final timeA = usageA?['totalTimeInForeground'] ?? 0;
                      final timeB = usageB?['totalTimeInForeground'] ?? 0;
                      return timeB.compareTo(timeA);
                    });

                    final filteredApps = sortedApps.where((app) =>
                      (app.name ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      (app.packageName ?? '').toLowerCase().contains(_searchQuery.toLowerCase())
                    ).toList();

                    if (filteredApps.isEmpty) {
                      return Center(child: Text("No apps found", style: GoogleFonts.inter(color: Colors.white)));
                    }

                    return RefreshIndicator(
                      onRefresh: _loadUsageStats,
                      child: ListView.separated(
                        itemCount: filteredApps.length,
                        separatorBuilder: (context, index) => const Divider(color: AppColors.border, height: 1),
                        itemBuilder: (context, index) {
                          final appInfo = filteredApps[index];
                          final appName = appInfo.name ?? 'Unknown App';
                          final packageName = appInfo.packageName ?? '';
                          final limit = limits.where((l) => l.packageName == packageName).firstOrNull;
                          final usage = usageStats.where((u) => u['packageName'] == packageName).firstOrNull;
                          final usedDuration = usage != null ? Duration(milliseconds: usage['totalTimeInForeground'] ?? 0) : Duration.zero;

                          double progress = 0;
                          if (limit != null && limit.isEnabled && limit.dailyLimit.inSeconds > 0) {
                            progress = (usedDuration.inSeconds / limit.dailyLimit.inSeconds).clamp(0.0, 1.0);
                          }

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            leading: _AppIconWidget(packageName: packageName),
                            title: Text(
                              appName,
                              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  'Used today: ${_formatDuration(usedDuration)}',
                                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                                ),
                                if (limit != null && limit.isEnabled) ...[
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: Colors.white12,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        progress >= 1.0 ? Colors.red : AppColors.primary,
                                      ),
                                      minHeight: 4,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Limit: ${_formatDuration(limit.dailyLimit)} ${usedDuration > limit.dailyLimit ? '(Exceeded!)' : ''}',
                                    style: GoogleFonts.inter(
                                      color: usedDuration > limit.dailyLimit ? Colors.red : AppColors.primary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppIconWidget extends ConsumerWidget {
  final String packageName;
  const _AppIconWidget({required this.packageName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconAsync = ref.watch(appIconProvider(packageName));
    
    return Container(
      width: 48,
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: iconAsync.when(
        data: (icon) => icon != null 
            ? Image.memory(icon, width: 40, height: 40)
            : const Icon(Icons.android, color: AppColors.primary),
        loading: () => const SizedBox(width: 40, height: 40),
        error: (_, __) => const Icon(Icons.android, color: AppColors.primary),
      ),
    );
  }
}