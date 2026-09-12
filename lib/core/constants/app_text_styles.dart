import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String _fontInter = 'Inter';
  static const String _fontMono = 'IBMPlexMono';

  static const TextStyle displayLg = TextStyle(
    fontFamily: _fontInter,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );
  static const TextStyle heading1 = TextStyle(
    fontFamily: _fontInter,
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle heading2 = TextStyle(
    fontFamily: _fontInter,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle heading3 = TextStyle(
    fontFamily: _fontInter,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontInter,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontInter,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontInter,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle label = TextStyle(
    fontFamily: _fontInter,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: _fontInter,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle button = TextStyle(
    fontFamily: _fontInter,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );
  static const TextStyle statLg = TextStyle(
    fontFamily: _fontMono,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );
  static const TextStyle statMd = TextStyle(
    fontFamily: _fontMono,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle statSm = TextStyle(
    fontFamily: _fontMono,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );
}
