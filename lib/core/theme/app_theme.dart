import 'package:flutter/material.dart';

class AppColors {
  // Fondo y superficies
  static const background = Color(0xFF0F0F0F);
  static const surface = Color(0xFF1A1A1A);
  static const surfaceVariant = Color(0xFF242424);

  // Identidad JaCO dev — dorado/ámbar corporativo
  static const primary = Color(0xFFF5A623);
  static const primaryDark = Color(0xFFD4891A);
  static const onPrimary = Color(0xFF0F0F0F);

  // Textos
  static const onBackground = Color(0xFFE8E8E8);
  static const onSurface = Color(0xFFAAAAAA);

  // Estados del afinador
  static const tuned = Color(0xFF4CAF50);
  static const sharp = Color(0xFFF5A623);   // dorado JaCO = nota alta
  static const flat = Color(0xFFEF5350);    // rojo = nota baja

  // VU meter
  static const dbLow = Color(0xFF4CAF50);
  static const dbMid = Color(0xFFF5A623);
  static const dbHigh = Color(0xFFEF5350);
  static const dbPeak = Color(0xFFFF6F00);
  static const inactive = Color(0xFF383838);

  // Zonas del arco del afinador
  static const arcZoneGreen = Color(0x664CAF50);
  static const arcZoneYellow = Color(0x44F5A623);
  static const arcZoneRed = Color(0x44EF5350);

  // Efectos de glow/brillo
  static const tunedGlow = Color(0x404CAF50);
  static const brandGlow = Color(0x40F5A623);
  static const needleShadow = Color(0x88F5A623);
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
