import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryYellow,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryYellow,
        onPrimary: AppColors.textDark,
        surface: AppColors.surfaceWhite,
        onSurface: AppColors.textDark,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textDark),
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme;
}
