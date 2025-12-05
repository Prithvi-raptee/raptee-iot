import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/data/datasources/dashboard_remote_datasource.dart';
import '../../features/data/repositories/dashboard_repository.dart';
import '../../features/presentation/bloc/dashboard_bloc.dart';
import '../../features/presentation/bloc/dashboard_event.dart';
import '../../core/network/api_client.dart';
import '../../features/presentation/layout/main_layout.dart';
import '../../features/presentation/pages/bikes_page.dart';
import '../../features/presentation/pages/dashboard_page.dart';
import '../../features/presentation/pages/details_page.dart';
import '../../features/presentation/pages/map_page.dart';
import '../../features/data/models/bike_model.dart';

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
          // Initialize dependencies here (or use DI container like GetIt)
          final apiClient = ApiClient();
          final dataSource = DashboardRemoteDataSourceImpl(
            apiClient: apiClient,
          );
          final repository = DashboardRepository(remoteDataSource: dataSource);

          return RepositoryProvider(
            create: (context) => repository,
            child: BlocProvider(
              create: (context) =>
                  DashboardBloc(repository: repository)
                    ..add(const DashboardFetchAllBikesEvent()),
              child: SelectionArea(
                child: MainLayout(child: child),
              ),
            ),
          );
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
                  final bike = state.extra as BikeModel?;
                  return DetailsPage(bikeId: bikeId, bike: bike);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/bikes',
            name: 'bikes',
            builder: (context, state) => const BikesPage(),
          ),
          GoRoute(
            path: '/map',
            name: 'map',
            builder: (context, state) => const MapPage(),
          ),
          // Add other top-level routes here that should be inside the layout
          // e.g., /bikes, /map, /analytics, /users, /settings
        ],
      ),
    ],
  );
}
