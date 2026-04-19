import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../features/focus/focus_provider.dart';
import '../../features/dnd/dnd_service.dart';
import 'result_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../widgets/premium_background.dart';

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  final String _adUnitId = 'ca-app-pub-3940256099942544/6300978111'; // Google Banner Test ID

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focusState = ref.watch(focusProvider);

    if (focusState.status == FocusStatus.success || focusState.status == FocusStatus.failed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ResultScreen()),
        );
      });
    }

    final minutes = (focusState.remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (focusState.remainingSeconds % 60).toString().padLeft(2, '0');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.border)),
            title: Text('END SESSION?', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1, fontSize: 16)),
            content: Text('Focus progress will be lost. Are you sure?', style: GoogleFonts.inter(color: Colors.white70, fontSize: 14)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Stay focused')),
              TextButton(
                onPressed: () async {
                  ref.read(focusProvider.notifier).endSessionEarly();
                  if (context.mounted) Navigator.pop(context, true);
                },
                child: const Text('Quit', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
        if (shouldPop == true && context.mounted) {
           Navigator.pop(context);
        }
      },
      child: Scaffold(
        body: PremiumBackground(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(flex: 2),
                          Text(
                            'CURRENT FOCUS',
                            style: GoogleFonts.inter(color: Colors.white38, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold),
                          ).animate().fadeIn(),
                          const SizedBox(height: 8),
                          Text(
                            'Deep Work Session',
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                          ).animate().fadeIn(delay: 200.ms),
                          
                          const Spacer(flex: 3),
                          
                          // Minimalist Timer
                          Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 240,
                                  height: 240,
                                  child: CircularProgressIndicator(
                                    value: focusState.totalSeconds > 0 ? focusState.remainingSeconds / focusState.totalSeconds : 0,
                                    color: AppColors.primary,
                                    backgroundColor: Colors.white.withOpacity(0.03),
                                    strokeWidth: 2,
                                    strokeCap: StrokeCap.round,
                                  ),
                                ).animate(onPlay: (c) => c.repeat(reverse: true))
                                 .scale(begin: const Offset(1,1), end: const Offset(1.05, 1.05), duration: 4.seconds),
                                
                                Text(
                                  '$minutes:$seconds',
                                  style: GoogleFonts.inter(
                                    fontSize: 64,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -2,
                                  ),
                                ).animate().fadeIn(delay: 400.ms),
                              ],
                            ),
                          ),
                          
                          const Spacer(flex: 5),
                          
                          IconButton(
                            onPressed: () => Navigator.maybePop(context),
                            icon: const Icon(Icons.close_rounded, color: Colors.white60, size: 28),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.05),
                              padding: const EdgeInsets.all(20),
                              shape: const CircleBorder(),
                            ),
                          ).animate().fadeIn(delay: 1.seconds),
                          
                          const Spacer(),
                          
                          // AdMob Banner ad placement
                          if (_bannerAd != null && _isAdLoaded)
                            SafeArea(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                width: _bannerAd!.size.width.toDouble(),
                                height: _bannerAd!.size.height.toDouble(),
                                child: AdWidget(ad: _bannerAd!),
                              ).animate().fadeIn(delay: 500.ms),
                            )
                          else
                            const SizedBox(height: 62), // Placeholder height
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
