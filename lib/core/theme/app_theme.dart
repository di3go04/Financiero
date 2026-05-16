import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors - High contrast Fintech Palette
  static const Color primaryEmerald = Color(0xFF10B981);
  static const Color primaryIndigo = Color(0xFF6366F1);
  static const Color accentAmber = Color(0xFFF59E0B);
  
  // Status Colors
  static const Color incomeTeal = Color(0xFF059669);
  static const Color expenseRose = Color(0xFFE11D48);
  static const Color warningOrange = Color(0xFFD97706);

  // Backgrounds & Surfaces (OPAQUE)
  static const Color bgDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF334155);
  
  static const Color bgLight = Color(0xFFF8FAFC);
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
      primaryColor: primaryIndigo,
      scaffoldBackgroundColor: bgLight,
      cardColor: surfaceLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryIndigo,
        brightness: Brightness.light,
        surface: surfaceLight,
        onSurface: textSlate,
        primary: primaryIndigo,
        secondary: primaryEmerald,
        error: expenseRose,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgLight,
        elevation: 0,
        iconTheme: IconThemeData(color: textSlate),
        titleTextStyle: TextStyle(color: textSlate, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: borderLight)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: borderLight)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryIndigo, width: 2)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryIndigo,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryIndigo,
      scaffoldBackgroundColor: bgDark,
      cardColor: surfaceDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryIndigo,
        brightness: Brightness.dark,
        surface: surfaceDark,
        onSurface: textSnow,
        primary: primaryIndigo,
        secondary: primaryEmerald,
        error: expenseRose,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        iconTheme: IconThemeData(color: textSnow),
        titleTextStyle: TextStyle(color: textSnow, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: borderDark)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: borderDark)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryIndigo, width: 2)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryIndigo,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
    );
  }

  static Color categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'comida': return const Color(0xFFF59E0B);
      case 'transporte': return const Color(0xFF3B82F6);
      case 'ocio': return const Color(0xFF8B5CF6);
      case 'vivienda': return const Color(0xFF10B981);
      case 'salud': return const Color(0xFFEF4444);
      case 'suscripciones': return const Color(0xFFEC4899);
      case 'educación': return const Color(0xFF06B6D4);
      case 'compras': return const Color(0xFFF97316);
      case 'viajes': return const Color(0xFF6366F1);
      default: return const Color(0xFF64748B);
    }
  }
}
