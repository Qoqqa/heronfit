import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeronFitTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: primary,
    scaffoldBackgroundColor: bgLight,
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
  static const Color textMuted = Color(0xFF737285);
  static const Color success = Color(0xFF81C784);
  static const Color error = Color(0xFFE57373);
  static const Color warning = Color(0xFFFFB74D);
  static const Color info = Color(0xFF4FC3F7);
  static const Color dropShadow = Colors.black26;

  // ✅ Typography (Material Design 3)
  static final TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(
      fontSize: 57,
      fontWeight: FontWeight.w700,
      color: textPrimary,
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 45,
      fontWeight: FontWeight.w700,
      color: textPrimary,
    ),
    displaySmall: GoogleFonts.poppins(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      color: textPrimary,
    ),
    headlineLarge: GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      color: textPrimary,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: textPrimary,
    ),
    titleSmall: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: textPrimary,
    ),
    bodyLarge: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: textPrimary,
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: textSecondary,
    ),
    bodySmall: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: textMuted,
    ),
    labelLarge: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: textPrimary,
    ),
    labelMedium: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: textSecondary,
    ),
    labelSmall: GoogleFonts.poppins(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: textMuted,
    ),
  );
}
