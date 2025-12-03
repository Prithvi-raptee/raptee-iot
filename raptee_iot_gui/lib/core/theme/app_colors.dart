import 'package:flutter/material.dart';

class AppColors {
  // --- Primitive Palette (Edit these later to change the whole app) ---
  static const Color _black = Color(0xFF000000);
  static const Color _darkGrey = Color(0xFF121212); // Card BG
  static const Color _lightGrey = Color(0xFFE0E0E0);
  static const Color _brandPrimary = Color(0xFF00FF94); // Neon Green
  static const Color _brandSecondary = Color(0xFF2979FF); // Tech Blue
  static const Color _errorRed = Color(0xFFFF2E2E);
  static const Color _warningOrange = Color(0xFFFFC107);

  // --- Semantic Colors (Use these in your UI Widgets) ---
  
  // Base
  static const Color background = _black;
  static const Color surface = _darkGrey; // Cards, Sidebars
  static const Color onBackground = _lightGrey;
  static const Color border = Color(0xFF333333);

  // Brand
  static const Color primary = _brandPrimary;
  static const Color secondary = _brandSecondary;

  // Functional Status
  static const Color success = _brandPrimary;
  static const Color error = _errorRed;
  static const Color warning = _warningOrange;
  static const Color info = _brandSecondary;

  // Typography
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textInverse = _black;
}