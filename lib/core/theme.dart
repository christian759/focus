import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFF0D0D0D); // Slightly elevated black
  static const Color primary = Color(0xFF00E5A0); // Vibrant Electric Teal
  static const Color primaryGlow = Color(0x2600E5A0); // Brighter glow
  static const Color accent = Color(0xFF00B8D4); // Vibrant Cyan
  static const Color error = Color(0xFFFF5252);
  static const Color text = Colors.white;
  static const Color textSecondary = Color(0xFFA0A0A0);
  static const Color cardBackground = Color(0xFF161616);
  static const Color glassBackground = Color(0x08FFFFFF);
  static const Color border = Color(0xFF222222);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        onPrimary: AppColors.background,
        error: AppColors.error,
        surface: AppColors.cardBackground,
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.inter(
          color: AppColors.text, 
          fontWeight: FontWeight.bold,
          letterSpacing: -1.0,
        ),
        headlineMedium: GoogleFonts.inter(
          color: AppColors.text, 
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.inter(
          color: AppColors.text, 
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.inter(color: AppColors.text),
        bodyMedium: GoogleFonts.inter(color: AppColors.text),
        bodySmall: GoogleFonts.inter(color: AppColors.textSecondary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
    );
  }

  static BoxDecoration glassDecoration = BoxDecoration(
    color: AppColors.glassBackground,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.border, width: 1),
  );

  static LinearGradient primaryGradient = const LinearGradient(
    colors: [AppColors.primary, AppColors.accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
