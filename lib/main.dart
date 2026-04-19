import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'services/hive_service.dart';
import 'ui/screens/main_layout_screen.dart';
import 'ui/screens/onboarding_screen.dart';
import 'services/alarm_service.dart';
import 'features/focus/lifecycle_observer.dart';
import 'features/user/user_provider.dart';



import 'ui/screens/initializing_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'features/dnd/global_block_orchestrator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: FocusPlusApp(),
    ),
  );
}

class FocusPlusApp extends ConsumerStatefulWidget {
  const FocusPlusApp({super.key});

  @override
  ConsumerState<FocusPlusApp> createState() => _FocusPlusAppState();
}

class _FocusPlusAppState extends ConsumerState<FocusPlusApp> {
  late LifecycleObserver _lifecycleObserver;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      await HiveService.init();
      await AlarmService.init();
      await MobileAds.instance.initialize();
    } catch (e) {
      debugPrint('Initialization error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _lifecycleObserver = ref.read(lifecycleObserverProvider);
          WidgetsBinding.instance.addObserver(_lifecycleObserver);
        });
      }
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    ref.watch(globalBlockOrchestratorProvider);

    if (!_isInitialized || userState.isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const InitializingScreen(),
      );
    }

    return MaterialApp(
      title: 'Focus+',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: userState.hasSeenOnboarding ? const MainLayoutScreen() : const OnboardingScreen(),
    );
  }
}
