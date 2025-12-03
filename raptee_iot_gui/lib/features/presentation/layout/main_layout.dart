import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_manager.dart';
import 'sidebar.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Row(
        children: [
          // Persistent Sidebar
          const Sidebar(),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration:  BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    border: Border(bottom: BorderSide(color: theme.dividerColor)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Breadcrumbs or Page Title (Placeholder)
                      Text('Dashboard', style: AppTypography.h3.copyWith(color: theme.colorScheme.onSurface)),

                      // Header Actions
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(TablerIcons.search, color: theme.colorScheme.onSurfaceVariant),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 8),
                          // Theme Toggle
                          ValueListenableBuilder<ThemeMode>(
                            valueListenable: ThemeManager.themeMode,
                            builder: (context, themeMode, child) {
                              final isDark = themeMode == ThemeMode.dark;
                              return IconButton(
                                icon: Icon(
                                  isDark ? TablerIcons.sun : TablerIcons.moon,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                onPressed: ThemeManager.toggleTheme,
                                tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Page Content
                Expanded(
                  child: child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
