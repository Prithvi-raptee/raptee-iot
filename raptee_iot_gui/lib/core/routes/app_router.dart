import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../features/presentation/layout/main_layout.dart';
import '../../features/presentation/pages/bikes_page.dart';
import '../../features/presentation/pages/dashboard_page.dart';
import '../../features/presentation/pages/details_page.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'dashboard',
            builder: (context, state) => const DashboardPage(),
            routes: [
              GoRoute(
                path: 'details/:bikeId',
                name: 'details',
                builder: (context, state) {
                  final bikeId = state.pathParameters['bikeId']!;
                  return DetailsPage(bikeId: bikeId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/bikes',
            name: 'bikes',
            builder: (context, state) => const BikesPage(),
          ),
          // Add other top-level routes here that should be inside the layout
          // e.g., /bikes, /map, /analytics, /users, /settings
        ],
      ),
    ],
  );
}