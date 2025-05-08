import 'package:flutter/material.dart';

class HeronFitTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: primary,
    scaffoldBackgroundColor: bgLight,
    fontFamily: 'Poppins',
    textTheme: textTheme,
    colorScheme: ColorScheme.light(
      primary: primary,
      secondary: primaryDark,
      background: bgLight,
      onBackground: textPrimary,
      surface: Colors.white,
      onSurface: textPrimary,
      error: error,
      onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primary,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: textTheme.titleLarge?.copyWith(color: Colors.white),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: primary,
      unselectedItemColor: textMuted,
    ),
  );

  // ✅ Colors
  static const Color primary = Color(0xFF2F27CE);
  static const Color primaryDark = Color(0xFF443DFF);
  static const Color bgLight = Color(0xFFFBFBFE);
  static const Color bgPrimary = Color(0xFFDDD8FF);
  static const Color bgSecondary = Color(0xFFE2E1FF);
  static const Color textDark = Color(0xFF040316);
  static const Color textPrimary = Color(0xFF2C2B3B);
  static const Color textSecondary = Color(0xFF545461);
  static const Color textWhite = Colors.white;
  static const Color textMuted = Color(0xFF737285);
  static const Color success = Color(0xFF81C784);
  static const Color error = Color(0xFFE57373);
  static const Color warning = Color(0xFFFFB74D);
  static const Color info = Color(0xFF4FC3F7);
  static const Color dropShadow = Colors.black26;

  // Define reusable card shadow based on the progress screen style
  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      blurRadius: 40,
      color: Colors.black.withOpacity(0.1), // 10% opacity black
      offset: const Offset(0, 10),
    ),
  ];

  // ✅ Typography (Material Design 3)
  static final TextTheme textTheme = TextTheme(
    displayLarge: const TextStyle(
      fontFamily: 'ClashDisplay',
      fontSize: 57,
      fontWeight: FontWeight.w700,
      color: textPrimary,
      letterSpacing: -0.25,
      height: 1.12,
    ),
    displayMedium: const TextStyle(
      fontFamily: 'ClashDisplay',
      fontSize: 45,
      fontWeight: FontWeight.w700,
      color: textPrimary,
      letterSpacing: 0,
      height: 1.15,
    ),
    displaySmall: const TextStyle(
      fontFamily: 'ClashDisplay',
      fontSize: 36,
      fontWeight: FontWeight.w700,
      color: textPrimary,
      letterSpacing: 0,
      height: 1.22,
    ),
    headlineLarge: const TextStyle(
      fontFamily: 'ClashDisplay',
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: textPrimary,
      letterSpacing: 0,
      height: 1.25,
    ),
    headlineMedium: const TextStyle(
      fontFamily: 'ClashDisplay',
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: textPrimary,
      letterSpacing: 0,
      height: 1.28,
    ),
    headlineSmall: const TextStyle(
      fontFamily: 'ClashDisplay',
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      letterSpacing: 0,
      height: 1.33,
    ),
    titleLarge: const TextStyle(
      fontFamily: 'ClashDisplay',
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      letterSpacing: 0.1,
      height: 1.4,
    ),
    titleMedium: const TextStyle(
      fontFamily: 'ClashDisplay',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      letterSpacing: 0.15,
      height: 1.5,
    ),
    titleSmall: const TextStyle(
      fontFamily: 'ClashDisplay',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      letterSpacing: 0.1,
      height: 1.43,
    ),
    bodyLarge: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: textPrimary,
      letterSpacing: 0.5,
      height: 1.5,
    ),
    bodyMedium: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: textSecondary,
      letterSpacing: 0.25,
      height: 1.43,
    ),
    bodySmall: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: textMuted,
      letterSpacing: 0.4,
      height: 1.33,
    ),
    labelLarge: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: textPrimary,
      letterSpacing: 0.1,
      height: 1.43,
    ),
    labelMedium: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: textSecondary,
      letterSpacing: 0.5,
      height: 1.33,
    ),
    labelSmall: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: textMuted,
      letterSpacing: 0.5,
      height: 1.45,
    ),
  );
}
