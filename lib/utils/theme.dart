import 'package:flutter/material.dart';

class DocBrainTheme {
  // Color palette - Must be static const to be used in const constructors
  static const Color bgDeep = Color(0xFF050811);
  static const Color bgCard = Color(0xFF0D1117);
  static const Color bgCardLight = Color(0xFF161B27);
  static const Color neonCyan = Color(0xFF00F5FF);
  static const Color neonPurple = Color(0xFFBF5FFF);
  static const Color neonPink = Color(0xFFFF2D78);
  static const Color neonGreen = Color(0xFF00FF88);
  static const Color neonOrange = Color(0xFFFF6B35);
  static const Color textPrimary = Color(0xFFE8EAED);
  static const Color textSecondary = Color(0xFF8B9AB5);
  static const Color borderGlow = Color(0xFF1E2D4A);

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgDeep,

        // Removed 'const' here because it can cause issues if colors are modified
        colorScheme: const ColorScheme.dark(
          primary: neonCyan,
          secondary: neonPurple,
          tertiary: neonPink,
          surface: bgCard,
          onPrimary: bgDeep,
          onSecondary: textPrimary,
          onSurface: textPrimary,
          // Added for better Material 3 compatibility
          outline: borderGlow,
        ),

        fontFamily: 'Rajdhani',

        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: textPrimary,
            letterSpacing: 2,
          ),
          displayMedium: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          headlineLarge: TextStyle(
            fontFamily: 'Exo 2',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Exo 2',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 16,
            color: textSecondary,
            height: 1.6,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 14,
            color: textSecondary,
          ),
          labelLarge: TextStyle(
            fontFamily: 'Exo 2',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),

        cardTheme: CardThemeData(
          color: bgCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: borderGlow, width: 1),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: neonCyan,
            foregroundColor: bgDeep,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(
              fontFamily: 'Exo 2',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: bgCardLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderGlow),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderGlow),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: neonCyan, width: 1.5),
          ),
          hintStyle:
              const TextStyle(color: textSecondary, fontFamily: 'Rajdhani'),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
}
