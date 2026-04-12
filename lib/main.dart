import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'services/hive_service.dart';
import 'ui/screens/home_screen.dart';
import 'features/focus/lifecycle_observer.dart';

import 'ui/widgets/global_donate_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  
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

  @override
  void initState() {
    super.initState();
    _lifecycleObserver = ref.read(lifecycleObserverProvider);
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus+',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      builder: (context, child) {
        return GlobalDonateButton(
          child: child ?? const SizedBox(),
        );
      },
      home: const HomeScreen(),
    );
  }
}
