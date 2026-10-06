import 'package:flutter/material.dart';

/// Screen Breakpoint Constants
class AppBreakpoints {
  AppBreakpoints._();

  static const double mobileMax = 600;
  static const double tabletMax = 1024;
}

/// Helper widget to build responsive layouts for Mobile, Tablet, and Desktop
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < AppBreakpoints.mobileMax;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppBreakpoints.mobileMax &&
      MediaQuery.sizeOf(context).width < AppBreakpoints.tabletMax;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppBreakpoints.tabletMax;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppBreakpoints.tabletMax) {
          return desktop ?? tablet ?? mobile;
        }
        if (constraints.maxWidth >= AppBreakpoints.mobileMax) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}
