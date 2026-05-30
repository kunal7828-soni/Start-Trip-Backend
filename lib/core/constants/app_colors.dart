import 'package:flutter/material.dart';

/// Premium harmonized color system for Trip Buddy.
/// Built with vibrant gradients, glassmorphism layers, and deep neutral surfaces.
class AppColors {
  AppColors._();

  // Branding Colors
  static const Color primary = Color(0xFF0F766E); // Rich Teal
  static const Color primaryLight = Color(0xFF0D9488); // Teal hover
  static const Color secondary = Color(0xFFF43F5E); // Soft Coral Rose (Accent)
  static const Color secondaryLight = Color(0xFFFB7185);

  // Functional Status Colors
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Rose Red
  static const Color info = Color(0xFF3B82F6); // Celestial Blue

  // Light Theme Neutrals
  static const Color bgLight = Color(0xFFF8FAFC); // Cool Slate background
  static const Color cardLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF0F172A); // Midnight Navy
  static const Color textSecondaryLight = Color(0xFF475569); // Slate Grey
  static const Color borderLight = Color(0xFFE2E8F0); // Subtle Slate border

  // Dark Theme Neutrals
  static const Color bgDark = Color(0xFF0B0F19); // Deep Obsidian
  static const Color cardDark = Color(0xFF131C2E); // Deep Space Blue Card
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Off-White
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Muted Slate Grey
  static const Color borderDark = Color(0xFF1E293B); // Dark Slate border

  // Gradients
  static const Gradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF0369A1)], // Teal to Sky Blue
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient darkGradient = LinearGradient(
    colors: [bgDark, Color(0xFF0F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Gradient accentGradient = LinearGradient(
    colors: [secondary, Color(0xFFD946EF)], // Coral Rose to Fuchsia
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
