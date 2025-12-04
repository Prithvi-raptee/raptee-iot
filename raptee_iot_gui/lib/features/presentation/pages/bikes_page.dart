import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_typography.dart';
import '../../data/models/bike_model.dart';
import '../widgets/custom_error_widget.dart';

class BikesPage extends StatefulWidget {
  const BikesPage({super.key});

  @override
  State<BikesPage> createState() => _BikesPageState();
}

class _BikesPageState extends State<BikesPage> {
  late final DashboardRepository _repository;

  @override
  void initState() {
    super.initState();
    // Initialize dependencies once
    // TODO: Ideally this should be provided via DI (GetIt/Provider)
    final apiClient = ApiClient();
    final dataSource = DashboardRemoteDataSourceImpl(apiClient: apiClient);
    _repository = DashboardRepository(remoteDataSource: dataSource);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DashboardBloc(repository: _repository)
            ..add(const DashboardFetchAllBikesEvent()),
      child: const _BikesView(),
    );
  }
}

class _BikesView extends StatelessWidget {
  const _BikesView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        // Show loading only on initial load, not on refresh if data exists
        if (state.status == DashboardStatus.loading && state.bikes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == DashboardStatus.failure && state.bikes.isEmpty) {
          return Center(
            child: CustomErrorWidget(
              message: state.errorMessage ?? 'An unexpected error occurred',
              onRetry: () {
                context.read<DashboardBloc>().add(
                  const DashboardFetchAllBikesEvent(),
                );
              },
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "All Bikes",
                    style: AppTypography.h2.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Row(
                    children: [
                      if (state.status == DashboardStatus.loading)
                        const Padding(
                          padding: EdgeInsets.only(right: 16.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ElevatedButton.icon(
                        onPressed: state.status == DashboardStatus.loading
                            ? null
                            : () {
                                context.read<DashboardBloc>().add(
                                  const DashboardFetchAllBikesEvent(),
                                );
                              },
                        icon: const Icon(TablerIcons.refresh, size: 18),
                        label: const Text("Refresh"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300, // Responsive width
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: state.bikes.length,
                  itemBuilder: (context, index) {
                    final bike = state.bikes[index];
                    return _BikeCard(bike: bike);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BikeCard extends StatelessWidget {
  final BikeModel bike;

  const _BikeCard({required this.bike});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      color: theme.cardColor,
      child: InkWell(
        onTap: () {
          context.goNamed('details', pathParameters: {'bikeId': bike.bikeId});
        },
        borderRadius: BorderRadius.circular(12),
        hoverColor: theme.hoverColor,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      TablerIcons.motorbike,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "Active",
                      style: AppTypography.caption.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                bike.bikeId,
                style: AppTypography.h3.copyWith(color: colorScheme.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                "${bike.metadata['model'] ?? 'Unknown Model'} • ${bike.metadata['color'] ?? 'Unknown Color'}",
                style: AppTypography.body.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    "View Analytics",
                    style: AppTypography.caption.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    TablerIcons.arrow_right,
                    size: 14,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
