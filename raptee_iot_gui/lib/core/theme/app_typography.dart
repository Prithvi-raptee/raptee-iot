import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // Headings
  static TextStyle get h1 => GoogleFonts.inter(
    fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary
  );

  static TextStyle get h2 => GoogleFonts.inter(
    fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary
  );

  static TextStyle get h3 => GoogleFonts.inter(
    fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary
  );

  // Body Text
  static TextStyle get body => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textPrimary
  );

  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary
  );

  // Data & Logs (Monospaced)
  static TextStyle get mono => GoogleFonts.jetBrainsMono(
    fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.primary
  );
}