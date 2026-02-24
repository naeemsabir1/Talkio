import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // New "Clean & Minimalist" Palette
  static const Color primary = Color(0xFF7C3AED); // Vibrant Violet/Purple (Medium Slate Blue ish)
  static const Color secondary = Color(0xFF8A9AF4); // Soft Periwinkle Blue
  static const Color accent = Color(0xFFF472B6); // Soft Pink Accent (optional for gradients)
  
  static const Color background = Color(0xFFFFFFFF); // Pure White
  static const Color surface = Color(0xFFF8FAFC); // Very light grey/blue tint
  static const Color surfaceHighlight = Color(0xFFE2E8F0); // Slate 200
  
  static const Color textPrimary = Color(0xFF1E293B); // Slate 800
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textTertiary = Color(0xFF94A3B8); // Slate 400
  
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);

  // Gradient helper (can be used in UI)
  static const LinearGradient coreGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, primary],
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        background: background,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
      ),
      
      // Typography - Outfit + Inter (Clean, readable on white)
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -1.0,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textSecondary, // Readable grey
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textSecondary,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
      ),
      
      // Component Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: secondary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: primary,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 8, // Subtle shadow for white theme
      ),
      
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 4, // Soft shadow for depth
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: surfaceHighlight, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: surfaceHighlight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary),
        ),
        hintStyle: GoogleFonts.inter(color: textTertiary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }
  
  // Dark Theme as fallback (optional, but requested Light)
  static ThemeData get darkTheme => lightTheme; // Force light for now as requested
}
