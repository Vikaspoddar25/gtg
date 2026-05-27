import 'package:flutter/material.dart';
import 'package:gtg/theme/app_colors.dart';

/// Spacing scale (8-pt grid)
abstract final class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  /// Responsive horizontal page padding
  static EdgeInsets pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1280) return const EdgeInsets.symmetric(horizontal: 120);
    if (width >= 768)  return const EdgeInsets.symmetric(horizontal: 48);
    return const EdgeInsets.symmetric(horizontal: 20);
  }
}

/// Shared border radius values from GTG Figma frames.
abstract final class AppRadius {
  static const double input = 17;
  static const double card = 20;
  static const double cardLarge = 39;
  static const double chip = 20;
  static const double panel = 32;
  static const double topSheet = 23;
}

/// Shared shadows used across cards/nav.
abstract final class AppShadows {
  static const BoxShadow card = BoxShadow(
    color: AppColors.cardShadow,
    offset: Offset(3, 7),
    blurRadius: 9.3,
  );

  static const BoxShadow nav = BoxShadow(
    color: AppColors.navShadow,
    offset: Offset(0, -4),
    blurRadius: 9.3,
  );
}

/// Shared gradients used in GTG screens.
abstract final class AppGradients {
  static const LinearGradient topHeader = LinearGradient(
    colors: [AppColors.gradientStart, AppColors.gradientEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient homeSurface = LinearGradient(
    begin: Alignment(0.6, -0.8),
    end: Alignment(-0.6, 0.8),
    colors: [
      Color(0x66CE3131),
      Color(0x66FFE9E9),
      Color(0x66FF7F7B),
    ],
    stops: [0.059, 0.471, 0.994],
  );
}

/// Typography scale — Roboto (system font on Android; web uses Google Fonts fallback)
abstract final class AppTextStyles {
  static const String _font = 'Roboto';

  static const TextStyle displayBrand = TextStyle(
    fontFamily: _font,
    fontSize: 30,
    fontWeight: FontWeight.w400,
    color: AppColors.textWhite,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: _font,
    fontSize: 25,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingSuccess = TextStyle(
    fontFamily: _font,
    fontSize: 25,
    fontWeight: FontWeight.w500,
    color: AppColors.success,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _font,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );

  static const TextStyle bodyDark = TextStyle(
    fontFamily: _font,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle ctaLabel = TextStyle(
    fontFamily: _font,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: AppColors.textWhite,
  );

  static const TextStyle timerLabel = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static const TextStyle linkLabel = TextStyle(
    fontFamily: _font,
    fontSize: 15,
    fontWeight: FontWeight.w300,
    color: AppColors.link,
  );

  static const TextStyle hintText = TextStyle(
    fontFamily: _font,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
  );

  static const TextStyle venueName = TextStyle(
    fontFamily: _font,
    fontSize: 25,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle venueDetail = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle venuePrice = TextStyle(
    fontFamily: _font,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static const TextStyle startLabel = TextStyle(
    fontFamily: _font,
    fontSize: 30,
    fontWeight: FontWeight.w400,
    color: AppColors.textWhite,
  );

  static const TextStyle locationText = TextStyle(
    fontFamily: _font,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: _font,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
}


