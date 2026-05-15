import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryCyan = Color(0xFF06B6D4);
  static const Color secondaryBlue = Color(0xFF2563EB);
  
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color bgDark = Color(0xFF020617);
  
  static const Color glassLight = Color(0xB3FFFFFF); // 0.7 opacity
  static const Color glassDark = Color(0x66020617);  // 0.4 opacity for better glass effect
  
  static const Color textDark = Color(0xFF1E293B);
  static const Color textLight = Color(0xFF64748B);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryCyan,
      scaffoldBackgroundColor: bgLight,
      cardColor: glassLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryCyan,
        primary: primaryCyan,
        secondary: secondaryBlue,
        surface: glassLight,
      ),
      textTheme: GoogleFonts.interTextTheme(const TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
        bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xFF334155)),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF64748B)),
      )),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.withValues(alpha: 0.05),
        border: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.transparent, width: 2),
        ),
        enabledBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.transparent, width: 2),
        ),
        focusedBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: emerald, width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFF64748B)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryCyan,
      scaffoldBackgroundColor: bgDark,
      cardColor: glassDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryCyan,
        brightness: Brightness.dark,
        primary: primaryCyan,
        secondary: const Color(0xFF3B82F6), // Lighter blue
        surface: glassDark,
      ),
      textTheme: GoogleFonts.interTextTheme(const TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.white),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white70),
      )),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.03),
        border: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.transparent, width: 2),
        ),
        enabledBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.transparent, width: 2),
        ),
        focusedBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: emerald, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
      ),
    );
  }
}
