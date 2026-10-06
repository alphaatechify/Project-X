import 'package:flutter/material.dart';

/// Accessibility utilities ensuring standard touch targets and semantics
class AccessibilityUtils {
  AccessibilityUtils._();

  /// Minimum recommended accessible touch target height/width (48.0 dp)
  static const double minTouchTargetSize = 48.0;

  /// Wraps a child widget in a Semantics widget with explicit label
  static Widget withSemantics({
    required Widget child,
    required String label,
    String? hint,
    bool isButton = false,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: isButton,
      child: child,
    );
  }
}
