import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

import '../../core/theme.dart';
import 'home_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';
import 'tasks_screen.dart';
import '../../features/dnd/dnd_service.dart';
import '../../features/navigation/navigation_provider.dart';

class MainLayoutScreen extends ConsumerStatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  ConsumerState<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends ConsumerState<MainLayoutScreen> {


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissions();
    });
  }

  Future<void> _checkPermissions() async {
    await DndService.requestDndPermission(context);
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const TasksScreen(),
    const StatsScreen(),
    const AppLimiterScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider);
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          IndexedStack(
            index: currentIndex,
            children: _screens,
          ),
          if (!isKeyboardVisible)
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      splashFactory: NoSplash.splashFactory,
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: BottomNavigationBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        type: BottomNavigationBarType.fixed,
                        currentIndex: currentIndex,
                        onTap: (index) {
                          ref.read(navigationProvider.notifier).state = index;
                        },
                        selectedItemColor: AppColors.primary,
                        unselectedItemColor: Colors.white54,
                        showSelectedLabels: false,
                        showUnselectedLabels: false,
                        items: const [
                          BottomNavigationBarItem(
                            icon: Icon(Icons.home_rounded),
                            label: 'Home',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.checklist_rounded),
                            label: 'Tasks',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.bar_chart_rounded),
                            label: 'Stats',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.timer_rounded),
                            label: 'App Limits',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.settings_rounded),
                            label: 'Settings',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
