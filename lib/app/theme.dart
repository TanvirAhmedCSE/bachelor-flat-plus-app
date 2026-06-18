import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2D6A4F);
  static const Color primaryLight = Color(0xFF6B6F9A);
  static const Color primaryFaint = Color(0xFFEEEFF6);

  // Accent: warm amber
  static const Color secondary = Color(0xFFF2A65A);
  static const Color secondaryFaint = Color(0xFFFDF3E7);

  // Highlight: dusty terracotta
  static const Color accent = Color(0xFFE07A5F);
  static const Color accentFaint = Color(0xFFFBEDE9);

  // Surfaces
  static const Color surface = Color(0xFFF8F7F4);
  static const Color customWhite = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFECE9E3);

  // Text
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF6E6B65);
  static const Color textWhite = Colors.white;
  static const Color textHint = Color(0xFFB0ACA6);

  // Semantic
  static const Color success = Color(0xFF4CAF82);
  static const Color warning = Color(0xFFF2A65A);
  static const Color error = Color(0xFFD95F5F);
  static const Color info = Color(0xFF5A8FA8);

  // Role colors
  static const Color adminColor = Color(0xFF3D405B);
  static const Color memberColor = Color(0xFF5A8FA8);
  static const Color pendingColor = Color(0xFFF2A65A);

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.40),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get secondaryShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.25),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get otherShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.10),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.surface,
      fontFamily: 'Nunito',
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.customWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: const TextStyle(
          color: AppColors.textHint,
          fontSize: 14,
          fontFamily: 'Nunito',
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontFamily: 'Nunito',
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.primary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'Nunito',
        ),
        prefixIconColor: AppColors.textHint,
      ),
    );
  }
}
