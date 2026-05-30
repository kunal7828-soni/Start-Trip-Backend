import 'package:flutter/material.dart';

/// Central spacing layout tokens for Trip Buddy.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Pre-configured Vertical Spacers
  static const Widget vXS = SizedBox(height: xs);
  static const Widget vSM = SizedBox(height: sm);
  static const Widget vMD = SizedBox(height: md);
  static const Widget vLG = SizedBox(height: lg);
  static const Widget vXL = SizedBox(height: xl);
  static const Widget vXXL = SizedBox(height: xxl);

  // Pre-configured Horizontal Spacers
  static const Widget hXS = SizedBox(width: xs);
  static const Widget hSM = SizedBox(width: sm);
  static const Widget hMD = SizedBox(width: md);
  static const Widget hLG = SizedBox(width: lg);
  static const Widget hXL = SizedBox(width: xl);
  static const Widget hXXL = SizedBox(width: xxl);
}
