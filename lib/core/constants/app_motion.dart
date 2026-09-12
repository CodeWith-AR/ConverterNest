import 'package:flutter/material.dart';

class AppMotion {
  AppMotion._();

  static const Duration navBounce = Duration(milliseconds: 250);
  static const Duration branchSlide = Duration(milliseconds: 400);
  static const Duration controlState = Duration(milliseconds: 220);
  static const Duration fadePage = Duration(milliseconds: 350);
  static const Duration progress = Duration(milliseconds: 450);
  static const Duration resultEntry = Duration(milliseconds: 750);
  static const Duration toast = Duration(seconds: 3);

  // Splash & Onboarding
  static const Duration splashLogo = Duration(milliseconds: 1000);
  static const Duration splashFade = Duration(milliseconds: 500);
  static const Duration splashText = Duration(milliseconds: 1400);
  static const Duration splashTotal = Duration(milliseconds: 3200);

  // Staggered entrance
  static const Duration staggerDelay = Duration(milliseconds: 100);
  static const Duration staggerEntry = Duration(milliseconds: 550);

  static const Curve bounceCurve = Curves.easeOutBack;
  static const Curve slideCurve = Curves.easeInOutCubic;
  static const Curve stateCurve = Curves.easeOut;
  static const Curve progressCurve = Curves.easeInOut;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeOutCubic = Curves.easeOutCubic;
}
