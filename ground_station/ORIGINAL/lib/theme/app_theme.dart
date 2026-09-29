import 'package:flutter/material.dart';

class AppColors {
  static const Color spaceNavy = Color(0xFF081020);
  static const Color deepSpace = Color(0xFF050A12);

  static const Color orbitalBlue = Color(0xFF1E3A8A);
  static const Color accentBlue = Color(0xFF168CFF);
  static const Color accentCyan = Color(0xFF00D4FF);

  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFBBF24);
  static const Color fault = Color(0xFFEF4444);

  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFFA7B1C2);

  static const Color cardBackground = Color(0xCC0C1726);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.deepSpace,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentBlue,
        secondary: AppColors.accentCyan,
        surface: AppColors.spaceNavy,
        error: AppColors.fault,
      ),
      fontFamily: 'Arial',
      useMaterial3: true,
    );
  }
}