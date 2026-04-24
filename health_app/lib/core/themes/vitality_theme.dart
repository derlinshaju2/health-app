import 'package:flutter/material.dart';
import 'shadcn_theme.dart';

/// Vitality-inspired Modern Theme for Health Monitoring App
/// Based on the clean, professional design language shown in the Vitality app
class VitalityTheme {
  // Primary Colors - Professional Blue Theme
  static const Color primary = Color(0xFF003C90); // Deep blue
  static const Color primaryLight = Color(0xFF1D59C1); // Light blue
  static const Color primaryDark = Color(0xFF002B63); // Dark blue
  static const Color accent = Color(0xFF006D37); // Health green

  // Secondary Colors
  static const Color secondary = Color(0xFF6BFE9C); // Mint green
  static const Color tertiary = Color(0xFFFF9E0B); // Warning orange
  static const Color error = Color(0xFFBA1A1A); // Alert red

  // Neutral Colors
  static const Color background = Color(0xFFF9F9FC); // Very light blue-gray
  static const Color surface = Color(0xFFEEEFF0); // Light gray-blue
  static const Color surfaceVariant = Color(0xFFE2E2E5); // Border color
  static const Color onPrimary = Color(0xFFFFFFFF); // White on primary
  static const Color onSurface = Color(0xFF1A1C1E); // Dark text
  static const Color onSurfaceVariant = Color(0xFF434653); // Medium text
  static const Color outline = Color(0xFF737784); // Border text

  // Status Colors
  static const Color success = Color(0xFF10B981); // Success green
  static const Color warning = Color(0xFFF59E0B); // Warning orange
  static const Color info = Color(0xFF3B82F6); // Info blue
  static const Color healthy = Color(0xFF006D37); // Healthy green
  static const Color elevated = Color(0xFFFF6B6B); // Elevated red

  // Modern Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient healthGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [success, healthy],
  );

  // Border Radius - Modern & Friendly
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 9999.0;

  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(radiusXl));

  // Spacing
  static const double gapXs = 4.0;
  static const double gapSm = 8.0;
  static const double gapMd = 16.0;
  static const double gapLg = 24.0;
  static const double gapXl = 32.0;

  // Shadows - Soft & Professional
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x0F003C90), // Primary with low opacity
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x0A003C90),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x0A003C90),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> shadowXl = [
    BoxShadow(
      color: Color(0x0A003C90),
      blurRadius: 30,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  // Typography - Modern & Clean
  static const TextStyle h1 = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
    color: onSurface,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    height: 1.3,
    color: onSurface,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: onSurface,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: onSurface,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: onSurface,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: onSurface,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: onSurfaceVariant,
  );

  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.25,
    height: 1.2,
    color: onSurface,
  );

  // Material Design 3 Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: accent,
        tertiary: tertiary,
        surface: surface,
        error: error,
        onPrimary: onPrimary,
        onSecondary: onSurface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: primary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: h2.copyWith(color: primary),
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadiusLg,
          side: BorderSide(color: surfaceVariant, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadiusMd,
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: h1,
        displayMedium: h2,
        displaySmall: h3,
        headlineMedium: h4,
        bodyLarge: bodyLarge,
        bodyMedium: body,
        bodySmall: bodySmall,
        labelLarge: label,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 4,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: primaryLight,
        secondary: secondary,
        tertiary: tertiary,
        surface: const Color(0xFF1E293B),
        error: error,
        onPrimary: onSurface,
        onSecondary: onSurface,
        onSurface: const Color(0xFFF8FAFC),
        onSurfaceVariant: const Color(0xFFB0B8C4),
        outline: const Color(0xFF334155),
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: primaryLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: h2.copyWith(color: primaryLight),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF1E293B),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadiusLg,
          side: BorderSide(color: const Color(0xFF334155), width: 1),
        ),
      ),
    );
  }

  // Health Status Colors
  static Color getHealthStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'excellent':
      case 'healthy':
      case 'normal':
        return healthy;
      case 'good':
        return success;
      case 'elevated':
      case 'warning':
        return warning;
      case 'high':
      case 'poor':
        return elevated;
      case 'critical':
        return error;
      default:
        return onSurfaceVariant;
    }
  }

  static Color getBMICategoryColor(double bmi) {
    if (bmi < 18.5) return const Color(0xFF3B82F6); // Underweight - Blue
    if (bmi < 25) return healthy; // Normal - Green
    if (bmi < 30) return warning; // Overweight - Orange
    return error; // Obese - Red
  }

  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Healthy Weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}