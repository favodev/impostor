import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema Cyberpunk/Noir para el juego Impostor
///
/// Implementa Material Design 3 con un esquema de colores oscuro
/// y acentos neón vibrantes para crear atmósfera de misterio
class AppTheme {
  // Colores principales - Paleta Cyberpunk/Noir
  static const Color primaryNeon = Color(0xFF00F5FF); // Cyan neón
  static const Color secondaryNeon = Color(0xFFFF00FF); // Magenta neón
  static const Color accentNeon = Color(0xFF39FF14); // Verde neón
  static const Color warningNeon = Color(0xFFFFD700); // Dorado neón
  static const Color dangerNeon = Color(0xFFFF3131); // Rojo neón

  // Colores de fondo
  static const Color backgroundDark = Color(0xFF0D0D0D); // Negro profundo
  static const Color surfaceDark = Color(0xFF1A1A2E); // Azul muy oscuro
  static const Color cardDark = Color(0xFF16213E); // Azul oscuro para cards

  // Colores de texto
  static const Color textPrimary = Color(0xFFE8E8E8);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF6B6B6B);

  /// Tema oscuro principal de la aplicación
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Esquema de colores Material 3
      colorScheme: const ColorScheme.dark(
        primary: primaryNeon,
        secondary: secondaryNeon,
        tertiary: accentNeon,
        surface: surfaceDark,
        error: dangerNeon,
        onPrimary: backgroundDark,
        onSecondary: backgroundDark,
        onSurface: textPrimary,
        onError: backgroundDark,
      ),

      // Scaffold y fondo
      scaffoldBackgroundColor: backgroundDark,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: primaryNeon,
          letterSpacing: 2,
        ),
        iconTheme: const IconThemeData(color: primaryNeon),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 8,
        shadowColor: primaryNeon.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: primaryNeon.withValues(alpha: 0.2), width: 1),
        ),
      ),

      // Elevated Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNeon,
          foregroundColor: backgroundDark,
          elevation: 8,
          shadowColor: primaryNeon.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.rajdhani(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),

      // Outlined Buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryNeon,
          side: const BorderSide(color: primaryNeon, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.rajdhani(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),

      // Text Buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondaryNeon,
          textStyle: GoogleFonts.rajdhani(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentNeon,
        foregroundColor: backgroundDark,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryNeon.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryNeon.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryNeon, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dangerNeon, width: 2),
        ),
        labelStyle: GoogleFonts.rajdhani(color: textSecondary),
        hintStyle: GoogleFonts.rajdhani(color: textMuted),
      ),

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryNeon,
        inactiveTrackColor: primaryNeon.withValues(alpha: 0.2),
        thumbColor: primaryNeon,
        overlayColor: primaryNeon.withValues(alpha: 0.2),
        valueIndicatorColor: primaryNeon,
        valueIndicatorTextStyle: GoogleFonts.orbitron(
          color: backgroundDark,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: surfaceDark,
        selectedColor: primaryNeon.withValues(alpha: 0.3),
        disabledColor: surfaceDark.withValues(alpha: 0.5),
        labelStyle: GoogleFonts.rajdhani(color: textPrimary),
        side: BorderSide(color: primaryNeon.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: primaryNeon.withValues(alpha: 0.2),
        thickness: 1,
      ),

      // Icon
      iconTheme: const IconThemeData(color: primaryNeon, size: 24),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: cardDark,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: primaryNeon.withValues(alpha: 0.3)),
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardDark,
        contentTextStyle: GoogleFonts.rajdhani(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryNeon,
        linearTrackColor: surfaceDark,
        circularTrackColor: surfaceDark,
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: GoogleFonts.orbitron(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: 2,
        ),
        displayMedium: GoogleFonts.orbitron(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: 1.5,
        ),
        displaySmall: GoogleFonts.orbitron(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineLarge: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.rajdhani(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineSmall: GoogleFonts.rajdhani(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.rajdhani(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.rajdhani(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleSmall: GoogleFonts.rajdhani(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textSecondary,
        ),
        bodyLarge: GoogleFonts.rajdhani(fontSize: 16, color: textPrimary),
        bodyMedium: GoogleFonts.rajdhani(fontSize: 14, color: textPrimary),
        bodySmall: GoogleFonts.rajdhani(fontSize: 12, color: textSecondary),
        labelLarge: GoogleFonts.rajdhani(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: 1,
        ),
        labelMedium: GoogleFonts.rajdhani(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textSecondary,
        ),
        labelSmall: GoogleFonts.rajdhani(fontSize: 10, color: textMuted),
      ),
    );
  }

  /// Decoración para contenedores con efecto neón
  static BoxDecoration neonBoxDecoration({
    Color color = primaryNeon,
    double borderRadius = 16,
    double glowIntensity = 0.3,
  }) {
    return BoxDecoration(
      color: cardDark,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: glowIntensity),
          blurRadius: 20,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: color.withValues(alpha: glowIntensity * 0.5),
          blurRadius: 40,
          spreadRadius: 2,
        ),
      ],
    );
  }

  /// Gradiente de fondo para pantallas
  static BoxDecoration get backgroundGradient {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [backgroundDark, Color(0xFF0F0F23), Color(0xFF1A0A2E)],
      ),
    );
  }
}
