import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:installed_apps/app_info.dart';
import '../../core/theme.dart';
import '../../features/dnd/block_apps_provider.dart';
import '../../features/app_list/app_list_provider.dart';

class BlockAppsScreen extends ConsumerStatefulWidget {
  const BlockAppsScreen({super.key});

  @override
  ConsumerState<BlockAppsScreen> createState() => _BlockAppsScreenState();
}

class _BlockAppsScreenState extends ConsumerState<BlockAppsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blockedApps = ref.watch(blockAppsProvider);
    final appsAsync = ref.watch(appListProvider);

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
                'Select apps to block. System apps like YouTube are included.',
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
                  error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
                  data: (apps) {
                    final filteredApps = apps.where((app) =>
                      (app.name ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      (app.packageName ?? '').toLowerCase().contains(_searchQuery.toLowerCase())
                    ).toList();

                    if (filteredApps.isEmpty) {
                      return Center(child: Text("No apps found", style: GoogleFonts.inter(color: Colors.white)));
                    }

                    return ListView.separated(
                      itemCount: filteredApps.length,
                      separatorBuilder: (context, index) => const Divider(color: AppColors.border, height: 1),
                      itemBuilder: (context, index) {
                        final appInfo = filteredApps[index];
                        final appName = appInfo.name ?? 'Unknown App';
                        final packageName = appInfo.packageName ?? '';
                        final isBlocked = blockedApps.contains(packageName);

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 4),
                          leading: _AppIconWidget(packageName: packageName),
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

