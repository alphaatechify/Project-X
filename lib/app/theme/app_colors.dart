import 'package:flutter/material.dart';

/// Design tokens: App colors matching the visual spec
class AppColors {
  AppColors._();

  // Primary Accent (Bright Taxi / Kinetic Yellow)
  static const Color primaryYellow = Color(0xFFFFE500);
  static const Color primaryYellowDark = Color(0xFFE6CF00);

  // Text Colors
  static const Color textDark = Color(0xFF0F172A); // Dark Navy / Near Black
  static const Color textSecondary = Color(0xFF64748B); // Slate Gray
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textAccentOrange = Color(0xFFD97706); // Auto-detect accent

  // Neutral Backgrounds & Surfaces
  static const Color background = Color(0xFFFAFAFC);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceLightGray = Color(0xFFF1F5F9);

  // Borders & Dividers
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderFocused = Color(0xFF0F172A);
  static const Color divider = Color(0xFFE2E8F0);

  // Status & Alerts
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);

  // Ambient Glow Colors
  static const Color ambientGlowYellow = Color(0xFFFFF9C4);
}
