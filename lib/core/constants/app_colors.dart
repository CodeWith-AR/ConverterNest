import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static bool isDark = true;

  // Canvas & Surfaces - Dark
  static const Color canvasDarkConst = Color(0xFF0B0E11);
  static const Color surfaceCardDarkConst = Color(0xFF1E2329);
  static const Color surfaceElevatedDarkConst = Color(0xFF2B3139);
  static const Color surfaceInputDarkConst = Color(0xFF1E2329);

  // Canvas & Surfaces - Light
  static const Color canvasLightConst = Color(0xFFF5F6F8);
  static const Color surfaceCardLightConst = Color(0xFFFFFFFF);
  static const Color surfaceElevatedLightConst = Color(0xFFEAECEF);
  static const Color surfaceInputLightConst = Color(0xFFFFFFFF);

  // Dynamic getters for canvas & surfaces
  static Color get canvasDark => isDark ? canvasDarkConst : canvasLightConst;
  static Color get canvasLight => canvasLightConst;
  static Color get surfaceCard => isDark ? surfaceCardDarkConst : surfaceCardLightConst;
  static Color get surfaceElevated => isDark ? surfaceElevatedDarkConst : surfaceElevatedLightConst;
  static Color get surfaceInput => isDark ? surfaceInputDarkConst : surfaceInputLightConst;

  // Primary Accent (Yellow — Binance Brand)
  static const Color primary = Color(0xFFFCD535);
  static const Color primaryActive = Color(0xFFF0B90B);
  static Color get primaryDisabled => isDark ? const Color(0xFF3A3A1F) : const Color(0xFFF5E8B7);
  static const Color onPrimary = Color(0xFF181A20);
  static const Color primaryGlow = Color(0x26FCD535); // 15% opacity

  // Text Colors
  static const Color textPrimaryDarkConst = Color(0xFFEAECEF);
  static const Color textStrongDarkConst = Color(0xFFFFFFFF);
  static const Color textSecondaryDarkConst = Color(0xFF707A8A);

  static const Color textPrimaryLightConst = Color(0xFF181A20);
  static const Color textStrongLightConst = Color(0xFF000000);
  static const Color textSecondaryLightConst = Color(0xFF6B7280);

  static Color get textPrimary => isDark ? textPrimaryDarkConst : textPrimaryLightConst;
  static Color get textStrong => isDark ? textStrongDarkConst : textStrongLightConst;
  static Color get textSecondary => isDark ? textSecondaryDarkConst : textSecondaryLightConst;
  static const Color textOnPrimary = Color(0xFF181A20);

  // Semantic
  static const Color success = Color(0xFF0ECB81);
  static const Color error = Color(0xFFF6465D);
  static const Color warning = Color(0xFFF0B90B);
  static const Color info = Color(0xFF3B82F6);

  // Borders
  static const Color borderDarkConst = Color(0xFF2B3139);
  static const Color borderStrongDarkConst = Color(0xFF3D4654);
  static const Color borderLightConst = Color(0xFFE2E4E8);
  static const Color borderStrongLightConst = Color(0xFFCBD5E1);

  static Color get border => isDark ? borderDarkConst : borderLightConst;
  static Color get borderStrong => isDark ? borderStrongDarkConst : borderStrongLightConst;

  // Category accent colors (for icons & badges only — subtle tints)
  static const Color accentImage = Color(0xFF3B82F6); // Blue
  static const Color accentAudio = Color(0xFF8B5CF6); // Purple
  static const Color accentVideo = Color(0xFFEC4899); // Pink
  static const Color accentArchive = Color(0xFF10B981); // Emerald
  static const Color accentText = Color(0xFF06B6D4); // Cyan
  static const Color accentPdf = Color(0xFFF97316); // Orange
}
