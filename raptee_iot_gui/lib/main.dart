import 'package:flutter/material.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const RapteeIoTApp());
}

class RapteeIoTApp extends StatelessWidget {
  const RapteeIoTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Raptee IoT',
      
      // 1. Theme
      theme: AppTheme.dark,
      
      // 2. Router (Replaces 'home')
      routerConfig: AppRouter.router,
    );
  }
}