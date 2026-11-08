import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.rose,
      brightness: Brightness.light,
      surface: AppColors.surface,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Arial',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppColors.burgundy),
        headlineSmall: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.blush,
        labelTextStyle: WidgetStatePropertyAll(TextStyle(color: AppColors.burgundy, fontSize: 11, fontWeight: FontWeight.w700)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.rose,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        ),
      ),
    );
  }
}
