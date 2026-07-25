import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0D0D0D);
  static const surface = Color(0xFF1A1A1A);
  static const surfaceVariant = Color(0xFF242424);
  static const primary = Color(0xFF00E5FF);
  static const onPrimary = Color(0xFF0D0D0D);
  static const onBackground = Color(0xFFE0E0E0);
  static const onSurface = Color(0xFFB0B0B0);
  static const tuned = Color(0xFF00E676);
  static const sharp = Color(0xFFFFD740);
  static const flat = Color(0xFFFF5252);
  static const dbLow = Color(0xFF00E676);
  static const dbMid = Color(0xFFFFD740);
  static const dbHigh = Color(0xFFFF5252);
  static const inactive = Color(0xFF3A3A3A);
}

final appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      color: AppColors.onBackground,
      fontWeight: FontWeight.w300,
      letterSpacing: -2,
    ),
    titleMedium: TextStyle(
      color: AppColors.onSurface,
      letterSpacing: 2,
    ),
    bodySmall: TextStyle(
      color: AppColors.onSurface,
      fontSize: 12,
      letterSpacing: 1.5,
    ),
  ),
  iconTheme: const IconThemeData(color: AppColors.onSurface),
);
