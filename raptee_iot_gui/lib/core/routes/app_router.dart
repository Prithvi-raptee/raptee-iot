import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../features/presentation/pages/dashboard_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true, // Auto-print routes to console
    routes: [
      GoRoute(
        path: '/',
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
        routes: [
            
          // Add child routes here, e.g. /dashboard/details
          GoRoute(
            path: 'details/:bikeId',
            name: 'bike_details',
            builder: (context, state) {
              final bikeId = state.pathParameters['bikeId'];
              return const SizedBox(); // Replace with BikeDetailsPage(id: bikeId)
            },
          ),
        ],
      ),
    ],
  );
}