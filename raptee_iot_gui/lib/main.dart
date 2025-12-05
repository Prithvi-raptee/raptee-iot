import 'package:flutter/material.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_manager.dart';

void main() {
  runApp(const RapteeIoTApp());
}

class RapteeIoTApp extends StatelessWidget {
  const RapteeIoTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.themeMode,
      builder: (context, themeMode, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Raptee IoT',

          // 1. Theme
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,

          // 2. Router (Replaces 'home')
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
