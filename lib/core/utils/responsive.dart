import 'package:flutter/material.dart';

/// Screen size breakpoints.
class Breakpoints {
  Breakpoints._();

  static const double mobile = 600.0;
  static const double tablet = 1200.0;
}

/// Extension on BuildContext to fetch responsive states.
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Check if the screen is mobile-sized.
  bool get isMobile => screenWidth < Breakpoints.mobile;

  /// Check if the screen is tablet-sized.
  bool get isTablet => screenWidth >= Breakpoints.mobile && screenWidth < Breakpoints.tablet;

  /// Check if the screen is desktop-sized.
  bool get isDesktop => screenWidth >= Breakpoints.tablet;

  /// Select values dynamically based on screen configurations.
  T responsiveValue<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }
}

/// A responsive container choosing screens depending on active viewport bounds.
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.tablet && desktop != null) {
          return desktop!;
        }
        if (constraints.maxWidth >= Breakpoints.mobile && tablet != null) {
          return tablet!;
        }
        return mobile;
      },
    );
  }
}
