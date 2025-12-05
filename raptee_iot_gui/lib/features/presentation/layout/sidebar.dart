import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/assets.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Sidebar background color might be different from scaffold background in some designs,
    // but based on AppColors it was _surface1. In AppTheme, darkSurface is _surface1.
    // So we can use theme.cardColor or a specific extension if we had one.
    // For now, let's use theme.cardColor which maps to _surface1 in our theme setup.
    final sidebarColor = theme.cardColor; 

    return Container(
      width: 72, // Fixed width for rail
      color: sidebarColor,
      child: Column(
        children: [
          // Logo Area
          Container(
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
            ),
            child: SvgPicture.asset(Assets.logo(context), height: 28),
          ),

          const SizedBox(height: 16),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                _SidebarItem(
                  icon: TablerIcons.dashboard,
                  label: 'Dash',
                  route: '/',
                  isActive: GoRouterState.of(context).uri.toString() == '/',
                ),
                _SidebarItem(
                  icon: TablerIcons.motorbike,
                  label: 'Bikes',
                  route: '/bikes',
                  isActive: GoRouterState.of(
                    context,
                  ).uri.toString().startsWith('/bikes'),
                ),
                _SidebarItem(
                  icon: TablerIcons.map,
                  label: 'Map',
                  route: '/map',
                  isActive: GoRouterState.of(
                    context,
                  ).uri.toString().startsWith('/map'),
                ),
                _SidebarItem(
                  icon: TablerIcons.chart_dots,
                  label: 'Stats',
                  route: '/analytics',
                  isActive: GoRouterState.of(
                    context,
                  ).uri.toString().startsWith('/analytics'),
                ),
                const SizedBox(height: 24),
                // Separator or just space
                 Divider(color: theme.dividerColor, height: 24),
                _SidebarItem(
                  icon: TablerIcons.users,
                  label: 'Users',
                  route: '/users',
                  isActive: GoRouterState.of(
                    context,
                  ).uri.toString().startsWith('/users'),
                ),
                _SidebarItem(
                  icon: TablerIcons.settings,
                  label: 'Config',
                  route: '/settings',
                  isActive: GoRouterState.of(
                    context,
                  ).uri.toString().startsWith('/settings'),
                ),
              ],
            ),
          ),

          // User Profile / Footer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: theme.dividerColor)),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.hoverColor,
                  child: Icon(
                    TablerIcons.user,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                IconButton(
                  icon: Icon(
                    TablerIcons.logout,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {},
                  tooltip: 'Logout',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isActive;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go(route),
          borderRadius: BorderRadius.zero, // Sharp corners
          hoverColor: theme.hoverColor,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? colorScheme.primary : Colors.transparent,
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isActive
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: isActive
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
