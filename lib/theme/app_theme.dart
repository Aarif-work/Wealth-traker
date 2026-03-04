import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryWhite = Colors.white;
  static const Color softGray = Color(0xFFF5F5F7);
  static const Color mediumGray = Color(0xFFE5E5EA);
  static const Color textBlack = Color(0xFF1D1D1F);
  static const Color textGray = Color(0xFF86868B);
  
  // Accent Colors
  static const Color goldAccent = Color(0xFFFFD700);
  static const Color wealthGreen = Color(0xFF34C759);
  static const Color expenseRed = Color(0xFFFF3B30);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: primaryWhite,
      colorScheme: ColorScheme.light(
        surface: primaryWhite,
        primary: textBlack,
        secondary: goldAccent,
        onSurface: textBlack,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textBlack,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textBlack,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textBlack,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textBlack,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textGray,
        ),
      ),
      cardTheme: CardThemeData(
        color: softGray,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryWhite,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textBlack,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
