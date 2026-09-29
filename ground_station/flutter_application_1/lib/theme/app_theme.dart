import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color appBackground = Color(0xFF010B15);
  static const Color spaceNavy = Color(0xFF081020);
  static const Color deepSpace = appBackground;

  static const Color orbitalBlue = Color(0xFF19324C);
  static const Color accentBlue = Color(0xFF369CDA);
  static const Color accentCyan = Color(0xFF00D4FF);

  static const Color success = Color(0xFF80D478);
  static const Color warning = Color(0xFFFBBF24);
  static const Color fault = Color(0xFFEF4444);

  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color primaryText = Color(0xFFEBEBEB);
  static const Color textGray = Color(0xFFB8B8B8);
  static const Color mutedText = Color(0x997A7A7A);

  static const Color onlineCard = Color(0xFF11202E);
  static const Color offlineCard = Color(0xFF0F1821);
  static const Color offlineBorder = Color(0xFF4F6775);
  static const Color offlineBadge = Color(0xFF303C4D);

  static const Color cardBackground = onlineCard;
}

class AppTheme {
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.appBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentBlue,
        secondary: AppColors.accentCyan,
        surface: AppColors.onlineCard,
        error: AppColors.fault,
      ),
      textTheme: GoogleFonts.rajdhaniTextTheme(base.textTheme).apply(
        bodyColor: AppColors.primaryText,
        displayColor: AppColors.primaryText,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.primaryText,
      ),
    );
  }
}
