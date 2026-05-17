import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors - High Contrast Professional Palette (No Green/Pink)
  static const Color primaryBlue = Color(0xFF0052CC); // Pure Ocean Blue
  static const Color primarySlate = Color(0xFF64748B); // Slate
  static const Color accentAmber = Color(0xFFD97706); // Amber for warnings
  
  // Status Colors (Blue-based success instead of green)
  static const Color successBlue = Color(0xFF0EA5E9); // Sky Blue for incomes/success
  static const Color expenseRed = Color(0xFFB91C1C); // Dark Red for expenses
  static const Color infoCyan = Color(0xFF0891B2);

  // Backgrounds & Surfaces (OPAQUE, SOLID)
  static const Color bgDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF334155);
  
  static const Color bgLight = Color(0xFFF1F5F9);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Text Colors
  static const Color textSnow = Color(0xFFF8FAFC);
  static const Color textSlate = Color(0xFF1E293B);
  static const Color textDim = Color(0xFF94A3B8);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: bgLight,
      cardColor: surfaceLight,
      textTheme: GoogleFonts.interTextTheme(),
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: primaryBlue,
        onPrimary: Colors.white,
        secondary: primarySlate,
        onSecondary: Colors.white,
        error: expenseRed,
        onError: Colors.white,
        surface: surfaceLight,
        onSurface: textSlate,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgLight,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textSlate),
        titleTextStyle: GoogleFonts.inter(
          color: textSlate,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: bgDark,
      cardColor: surfaceDark,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: primaryBlue,
        onPrimary: Colors.white,
        secondary: primarySlate,
        onSecondary: Colors.white,
        error: expenseRed,
        onError: Colors.white,
        surface: surfaceDark,
        onSurface: textSnow,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textSnow),
        titleTextStyle: GoogleFonts.inter(
          color: textSnow,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static Color categoryColor(String category) {
    // Professional Financial Palette (Strictly No Green/Pink)
    switch (category.toLowerCase()) {
      case 'comida': return const Color(0xFF93C5FD); // Light Blue
      case 'transporte': return const Color(0xFF60A5FA); // Blue
      case 'ocio': return const Color(0xFF3B82F6); // Standard Blue
      case 'vivienda': return const Color(0xFF2563EB); // Royal Blue
      case 'salud': return const Color(0xFF1D4ED8); // Dark Blue
      case 'suscripciones': return const Color(0xFF1E40AF); // Deep Blue
      case 'educación': return const Color(0xFF0EA5E9); // Sky Blue
      case 'compras': return const Color(0xFF38BDF8); // Bright Light Blue
      default: return const Color(0xFF94A3B8); // Slate (fallback)
    }
  }
}
