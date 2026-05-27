import 'package:flutter/material.dart';

/// Design tokens extracted from Figma file wzigfuOA1J8AF0Mya8A1jr
abstract final class AppColors {
  // --- Brand primary (GTG red) ---
  static const Color primary = Color(0xFFCE3131);
  static const Color primaryLight = Color(0xFFFFF4F4);  // card bg
  static const Color primaryBorder = Color(0xFFCE5031); // card border
  static const Color onPrimary = Color(0xFFFFFFFF);

  // --- Gradient ---
  static const Color gradientStart = Color(0xFFFFFFFF);
  static const Color gradientEnd = Color(0xFFFFE1E0);

  // --- Text ---
  static const Color textPrimary = Color(0xFF3F3F3F);
  static const Color textHint = Color(0xFFEBEBEB);
  static const Color textWhite = Color(0xFFFFFFFF);

  // --- Status ---
  static const Color success = Color(0xFF6FD44C);
  static const Color link = Color(0xFF004AB9);
  static const Color statusBlue = Color(0xFF007FDB);
  static const Color statusDot = Color(0xFF007FDB);

  // --- Surface ---
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF3F3F3F);

  // --- Shadows ---
  static const Color cardShadow = Color(0x40CE3131); // rgba(206,49,49,0.25)
  static const Color navShadow = Color(0x40CE3131);

  // --- Misc ---
  static const Color divider = Color(0xFFEEEEEE);
  static const Color transparent = Colors.transparent;
}
