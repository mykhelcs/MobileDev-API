import 'package:flutter/material.dart';

/// Design tokens extracted from moviehub_ui.html.
abstract final class AppColors {
  // Backgrounds & Surfaces
  static const Color background   = Color(0xFF06091A);
  static const Color surface1     = Color(0xFF0D1233);
  static const Color surface2     = Color(0xFF141840);
  static const Color surface3     = Color(0xFF1C2154);

  // Accents & Brand
  static const Color accent       = Color(0xFF7C3AED);
  static const Color accentDim    = Color(0x2E7C3AED);
  static const Color accentGlow   = Color(0x597C3AED);

  // Highlights & Ratings
  static const Color gold         = Color(0xFFF59E0B);
  static const Color goldDim      = Color(0x26F59E0B);

  // Typography & Content
  static const Color textPrimary  = Color(0xFFF8FAFC);
  static const Color textMuted    = Color(0xFF94A3B8);
  static const Color textMuted2   = Color(0xFF4A5568);
  static const Color textPurpleDim = Color(0xFFC4B5FD);

  // Borders & Outlines
  static const Color border       = Color(0x12FFFFFF);
  static const Color border2      = Color(0x1FFFFFFF);

  // Destructive & Favorite Active
  static const Color heartRed     = Color(0xFFEF4444);
  static const Color heartRedDim  = Color(0x26EF4444);
}
