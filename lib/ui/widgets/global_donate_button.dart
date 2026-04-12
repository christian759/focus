import 'package:flutter/material.dart';
import '../screens/donate_screen.dart';
import '../../core/theme.dart';

class GlobalDonateButton extends StatelessWidget {
  final Widget child;

  const GlobalDonateButton({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          child,
          Positioned(
            right: 16,
            bottom: 32, // Provide some clearance for other FABs if necessary
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(100),
                onTap: () {
                  // We need to use the top-most navigator. Since this wraps MaterialApp's builder,
                  // we can use a GlobalKey<NavigatorState> or if we push via context, it might be the Navigator context.
                  // However, if GlobalDonateButton wraps inside MaterialApp.builder, accessing navigator via context is fine.
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(builder: (_) => const DonateScreen())
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
