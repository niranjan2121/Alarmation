import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.neumorphicBackground,
      primaryColor: AppColors.accentOrange, // Swapped to the new theme color
      fontFamily: 'Satoshi',
    );
  }
}

class AppTypography {
  static const TextStyle alarmHeader = TextStyle(
    fontFamily: 'ClashDisplay',
    fontSize: 56,
    fontWeight: FontWeight.bold,
    color: AppColors.pureBlack, // Swapped to pure black
    letterSpacing: 1.0,
  );

  static const TextStyle affirmationText = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textDark,
  );

  static const TextStyle interfaceLabel = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    letterSpacing: 0.5,
  );
}
