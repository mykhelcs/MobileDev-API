import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized typography using Playfair Display (display) and Outfit (UI).
abstract final class AppTypography {
  // Display / Editorial — Playfair Display
  static TextStyle heroTitle = GoogleFonts.playfairDisplay(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static TextStyle sectionHeadline = GoogleFonts.playfairDisplay(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle detailTitle = GoogleFonts.playfairDisplay(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // UI / Body — Outfit
  static TextStyle label = GoogleFonts.outfit(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  static TextStyle labelSmall = GoogleFonts.outfit(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static TextStyle chip = GoogleFonts.outfit(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPurpleDim,
  );

  static TextStyle rating = GoogleFonts.outfit(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.gold,
  );

  static TextStyle buttonLabel = GoogleFonts.outfit(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
  );

  static TextStyle bodyText = GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.7,
  );

  static TextStyle metaText = GoogleFonts.outfit(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static TextStyle cardTitle = GoogleFonts.outfit(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle navLabel = GoogleFonts.outfit(
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  static TextStyle tagline = GoogleFonts.outfit(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    color: AppColors.textPurpleDim,
  );

  static TextStyle statValue = GoogleFonts.outfit(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle statLabel = GoogleFonts.outfit(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    letterSpacing: 0.5,
  );
}
