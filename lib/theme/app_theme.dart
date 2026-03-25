import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // === Dark theme colors ===
  static const Color bgDark = Color(0xFF0D0D1A);
  static const Color bgCard = Color(0xFF1A1A2E);
  static const Color bgCardLight = Color(0xFF24243E);

  // === Light theme colors ===
  static const Color bgLight = Color(0xFFF5F5FA);
  static const Color bgCardLightTheme = Color(0xFFFFFFFF);
  static const Color bgCardLightAlt = Color(0xFFF0F0F8);

  // === Accent colors ===
  static const Color accentPurple = Color(0xFF7C3AED);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentRed = Color(0xFFEF4444);

  // === Text colors ===
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textPrimaryLight = Color(0xFF1E293B);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  static const List<Color> habitColors = [
    accentPurple,
    accentBlue,
    accentCyan,
    accentGreen,
    accentPink,
    accentOrange,
    accentRed,
    Color(0xFF8B5CF6),
  ];

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accentPurple, accentBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient urgentGradient = LinearGradient(
    colors: [accentRed, accentOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ========== DARK THEME ==========
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      primaryColor: accentPurple,
      colorScheme: const ColorScheme.dark(
        primary: accentPurple,
        secondary: accentBlue,
        surface: bgCard,
        onPrimary: textPrimary,
        onSecondary: textPrimary,
        onSurface: textPrimary,
      ),
      textTheme: _buildTextTheme(isDark: true),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentPurple,
        foregroundColor: textPrimary,
        elevation: 8,
        shape: CircleBorder(),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgCard,
        selectedItemColor: accentPurple,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accentPurple;
          return textMuted;
        }),
      ),
    );
  }

  // ========== LIGHT THEME ==========
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgLight,
      primaryColor: accentPurple,
      colorScheme: const ColorScheme.light(
        primary: accentPurple,
        secondary: accentBlue,
        surface: bgCardLightTheme,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryLight,
      ),
      textTheme: _buildTextTheme(isDark: false),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          color: textPrimaryLight,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentPurple,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: CircleBorder(),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgCardLightTheme,
        selectedItemColor: accentPurple,
        unselectedItemColor: textMutedLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accentPurple;
          return textMutedLight;
        }),
      ),
    );
  }

  static TextTheme _buildTextTheme({required bool isDark}) {
    final primary = isDark ? textPrimary : textPrimaryLight;
    final secondary = isDark ? textSecondary : textSecondaryLight;
    final muted = isDark ? textMuted : textMutedLight;

    return GoogleFonts.interTextTheme(
      TextTheme(
        headlineLarge: TextStyle(
            color: primary, fontWeight: FontWeight.w800, fontSize: 28, letterSpacing: -0.5),
        headlineMedium: TextStyle(
            color: primary, fontWeight: FontWeight.w700, fontSize: 22, letterSpacing: -0.3),
        titleLarge: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 18),
        titleMedium: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: TextStyle(color: primary, fontSize: 16),
        bodyMedium: TextStyle(color: secondary, fontSize: 14),
        bodySmall: TextStyle(color: muted, fontSize: 12),
      ),
    );
  }
}
