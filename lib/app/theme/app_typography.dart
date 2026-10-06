import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// App typography definitions using GoogleFonts (Plus Jakarta Sans & Inter)
class AppTypography {
  AppTypography._();

  static TextStyle headingLarge = GoogleFonts.plusJakartaSans(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
    height: 1.25,
    letterSpacing: -0.5,
  );

  static TextStyle titleMedium = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    letterSpacing: -0.2,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static TextStyle phoneInputText = GoogleFonts.plusJakartaSans(
    fontSize: 19,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    letterSpacing: 0.5,
  );

  static TextStyle buttonText = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle captionBold = GoogleFonts.inter(
    fontSize: 12.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textAccentOrange,
  );
}
