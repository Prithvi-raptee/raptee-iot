import 'package:flutter/material.dart';

class AppColors {
  // --- Primitive Palette ---
  static const Color _black = Color(0xFF000000);
  static const Color _white = Color(0xFFFFFFFF);
  
  // Dark Mode Primitives (Matte Style)
  static const Color _darkBg = Color(0xFF0F1115); // Deep matte dark background
  static const Color _darkSurface1 = Color(0xFF181B21); // Sidebar, Cards
  static const Color _darkSurface2 = Color(0xFF22262E); // Hover states, Inputs
  static const Color _darkSurface3 = Color(0xFF2D323B); // Borders, Dividers

  // Light Mode Primitives
  static const Color _lightBg = Color(0xFFF5F7FA); // Light gray background
  static const Color _lightSurface1 = Color(0xFFFFFFFF); // Sidebar, Cards
  static const Color _lightSurface2 = Color(0xFFE4E7EB); // Hover states, Inputs
  static const Color _lightSurface3 = Color(0xFFD1D5DB); // Borders, Dividers

  // Brand Colors (Blue Accent)
  static const Color _brandBlue = Color(0xFF2979FF); // Tech Blue
  static const Color _brandBlueLight = Color(0xFF63A4FF); // Lighter Blue for dark mode accent
  static const Color _brandBlueDark = Color(0xFF004ECB); // Darker Blue for light mode accent

  // Functional Colors
  static const Color _errorRed = Color(0xFFFF4C4C);
  static const Color _warningOrange = Color(0xFFFFB74D);
  static const Color _successGreen = Color(0xFF00E676);
  static const Color _infoBlue = Color(0xFF40C4FF);

  // Text Colors
  static const Color _textPrimaryDark = Color(0xFFFFFFFF);
  static const Color _textSecondaryDark = Color(0xFF9CA3AF);
  static const Color _textDisabledDark = Color(0xFF6B7280);

  static const Color _textPrimaryLight = Color(0xFF111827);
  static const Color _textSecondaryLight = Color(0xFF4B5563);
  static const Color _textDisabledLight = Color(0xFF9CA3AF);

  // --- Semantic Colors ---

  // Backgrounds
  static Color get background => _darkBg; // Default accessors for backward compatibility if needed, but Theme should handle this
  static Color get sidebar => _darkSurface1;
  
  // We will expose static colors for direct usage where context isn't available, 
  // but ideally we should use Theme.of(context) or specific getters for light/dark.
  // For now, I'll keep the static structure but add Light/Dark specific maps if needed, 
  // or just rely on the Theme to pick the right one.
  
  // Since the existing code uses AppColors.background directly, we might need to refactor 
  // usages to use Theme.of(context).colorScheme.background or similar.
  // However, to keep it simple as per request, I will define the palettes.

  // Dark Palette
  static const Color darkBackground = _darkBg;
  static const Color darkSidebar = _darkSurface1;
  static const Color darkSurface = _darkSurface1;
  static const Color darkSurfaceHover = _darkSurface2;
  static const Color darkCard = _darkSurface1;
  static const Color darkBorder = _darkSurface3;
  static const Color darkDivider = _darkSurface3;
  static const Color darkInputFill = _darkSurface2;

  // Light Palette
  static const Color lightBackground = _lightBg;
  static const Color lightSidebar = _lightSurface1;
  static const Color lightSurface = _lightSurface1;
  static const Color lightSurfaceHover = _lightSurface2;
  static const Color lightCard = _lightSurface1;
  static const Color lightBorder = _lightSurface3;
  static const Color lightDivider = _lightSurface3;
  static const Color lightInputFill = _lightSurface2;

  // Brand & Actions
  static const Color primary = _brandBlue;
  static const Color secondary = _brandBlue; // Unified to blue
  static const Color accent = _brandBlue; // Unified to blue

  // Functional Status
  static const Color success = _successGreen;
  static const Color error = _errorRed;
  static const Color warning = _warningOrange;
  static const Color info = _infoBlue;

  // Typography - Dark
  static const Color textPrimary = _textPrimaryDark;
  static const Color textSecondary = _textSecondaryDark;
  static const Color textDisabled = _textDisabledDark;
  static const Color textInverse = _black;

  // Typography - Light
  static const Color textPrimaryLight = _textPrimaryLight;
  static const Color textSecondaryLight = _textSecondaryLight;
  static const Color textDisabledLight = _textDisabledLight;
  static const Color textInverseLight = _white;
  
  // Icons
  static const Color iconDefault = _textSecondaryDark;
  static const Color iconActive = _textPrimaryDark;
}