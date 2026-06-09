import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryColor,
        secondary: AppColors.secondaryColor,
        surface: AppColors.cardColor,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.inter(color: AppColors.textPrimary),
        bodyMedium: GoogleFonts.inter(color: AppColors.textSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        shadowColor: Colors.black12,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.darkBackgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryColor,
        secondary: AppColors.secondaryColor,
        surface: AppColors.darkCardColor,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.inter(color: AppColors.textDarkPrimary),
        bodyMedium: GoogleFonts.inter(color: AppColors.textDarkSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkCardColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.darkCardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        shadowColor: Colors.black26,
      ),
    );
  }
}
