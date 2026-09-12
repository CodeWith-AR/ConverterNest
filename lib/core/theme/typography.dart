import 'package:flutter/material.dart';

TextTheme buildTextTheme() {
  return const TextTheme(
    displayLarge: TextStyle(
        fontFamily: 'Inter', fontSize: 32, fontWeight: FontWeight.w700),
    displayMedium: TextStyle(
        fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w700),
    displaySmall: TextStyle(
        fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w600),
    headlineLarge: TextStyle(
        fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w600),
    headlineMedium: TextStyle(
        fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(
        fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(
        fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(
        fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500),
    titleSmall: TextStyle(
        fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(
        fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(
        fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(
        fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w400),
    labelLarge: TextStyle(
        fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600),
    labelMedium: TextStyle(
        fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500),
    labelSmall: TextStyle(
        fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w500),
  );
}
