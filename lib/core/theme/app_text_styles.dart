import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Centralized typographic style configurations for Trip Buddy.
/// Coordinates Outfit (for headings and titles) and Inter (for descriptive text layers).
class AppTextStyles {
  AppTextStyles._();

  // Headings (Outfit Font)
  static TextStyle h1({Color? color}) => GoogleFonts.outfit(
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
        color: color ?? AppColors.textPrimaryLight,
        letterSpacing: -0.5,
      );

  static TextStyle h2({Color? color}) => GoogleFonts.outfit(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: color ?? AppColors.textPrimaryLight,
        letterSpacing: -0.3,
      );

  static TextStyle h3({Color? color}) => GoogleFonts.outfit(
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimaryLight,
      );

  // Subtitles & Titles (Outfit Font)
  static TextStyle title({Color? color}) => GoogleFonts.outfit(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimaryLight,
      );

  static TextStyle subtitle({Color? color}) => GoogleFonts.outfit(
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.textSecondaryLight,
      );

  // Body & Paragraphs (Inter Font)
  static TextStyle body({Color? color}) => GoogleFonts.inter(
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
        color: color ?? AppColors.textPrimaryLight,
        height: 1.5,
      );

  static TextStyle bodyMedium({Color? color}) => GoogleFonts.inter(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.textSecondaryLight,
      );

  static TextStyle caption({Color? color}) => GoogleFonts.inter(
        fontSize: 12.0,
        fontWeight: FontWeight.normal,
        color: color ?? AppColors.textSecondaryLight,
      );

  // Interactive Button Copy (Outfit Font)
  static TextStyle button({Color? color}) => GoogleFonts.outfit(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
        color: color ?? Colors.white,
        letterSpacing: 0.5,
      );
}
