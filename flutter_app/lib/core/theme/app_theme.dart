import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Khmer Royal & Warm Appetizing Colors from E-Restaurant variables.css
  static const Color primaryColor = Color(0xFF800020); // Deep Khmer Crimson / Burgundy
  static const Color primaryDark = Color(0xFF5C0017);
  static const Color primaryLight = Color(0xFFA31C38);
  static const Color primarySubtle = Color(0xFFFAE8EB);

  static const Color secondaryColor = Color(0xFFC59B27); // Angkor Warm Gold / Amber
  static const Color secondaryDark = Color(0xFF9E7A17);
  static const Color secondaryLight = Color(0xFFE5BE4F);
  static const Color secondarySubtle = Color(0xFFFDF8E6);

  static const Color accentColor = Color(0xFF2E7D32); // Organic Herb Green
  static const Color accentSubtle = Color(0xFFE8F5E9);

  static const Color backgroundColor = Color(0xFFFDFBF7); // Warm Ivory Cream
  static const Color cardColor = Colors.white;
  static const Color textDark = Color(0xFF231F1E); // Deep Charcoal
  static const Color textMuted = Color(0xFF6B635F);
  static const Color textLight = Color(0xFF9C948F);
  static const Color borderColor = Color(0xFFE8E2D8);

  static ThemeData get lightTheme {
    final base = ThemeData.light();
    final fontFamily = GoogleFonts.kantumruyPro().fontFamily;

    return base.copyWith(
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: cardColor,
      ),
      textTheme: base.textTheme.copyWith(
        headlineLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: textDark,
          height: 1.4,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textDark,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textDark,
          height: 1.45,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.normal,
          color: textMuted,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: textDark,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
      ),
    );
  }
}
