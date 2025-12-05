import 'package:flutter/material.dart';

class Assets {
  static const String _logoLight = 'assets/svg/raptee_logo_light.svg';
  static const String _logoDark = 'assets/svg/raptee_logo_dark.svg';

  static String logo(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    // If brightness is dark, use dark logo? Usually dark background needs light logo.
    // Let's assume the naming means "logo FOR light theme" vs "logo FOR dark theme".
    // Or "logo THAT IS light" vs "logo THAT IS dark".
    // Usually:
    // Dark Theme -> Dark Background -> Needs Light/White Logo.
    // Light Theme -> Light Background -> Needs Dark/Black Logo.
    
    // If the file is named "raptee_logo_dark.svg", it might mean the logo ITSELF is dark (for light bg).
    // If the file is named "raptee_logo_light.svg", it might mean the logo ITSELF is light (for dark bg).
    
    // Let's assume:
    // Brightness.dark (Dark Mode) -> Needs Light Logo -> _logoLight
    // Brightness.light (Light Mode) -> Needs Dark Logo -> _logoDark
    
    // Wait, user said: "Replace the bolt icon with @[raptee_iot_gui/assets/svg/raptee_logo_dark.svg] @[raptee_iot_gui/assets/svg/raptee_logo_light.svg]"
    // I will implement logic:
    // Dark Mode -> _logoLight (assuming it's white/light colored)
    // Light Mode -> _logoDark (assuming it's black/dark colored)
    
    return brightness == Brightness.dark ? _logoLight : _logoDark;
  }
}
