import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/chart_utils.dart';

class DetailsPage extends StatelessWidget {
  final String bikeId;

  const DetailsPage({super.key, required this.bikeId});

  @override
  Widget build(BuildContext context) {
    // Dependency Injection (Simple version for this scope)
    final apiClient = ApiClient();
    final dataSource = DashboardRemoteDataSourceImpl(apiClient: apiClient);
    final repository = DashboardRepository(remoteDataSource: dataSource);

    return BlocProvider(
      create: (context) => DashboardBloc(repository: repository)
        ..add(DashboardLoadEvent(bikeId)),
      child: const _DetailsView(),
    );
  }
}

class _DetailsView extends StatelessWidget {
  const _DetailsView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardBloc, DashboardState>(
      listener: (context, state) {
        if (state.deleteStatus == DeleteStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Operation Successful"),
              backgroundColor: AppColors.success,
            ),
          );
          context.goNamed('dashboard'); // Go back to list after delete
        } else if (state.deleteStatus == DeleteStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? "Operation Failed"),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == DashboardStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == DashboardStatus.failure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(TablerIcons.alert_triangle, color: AppColors.error, size: 48),
                const SizedBox(height: 16),
                Text("Error loading data", style: AppTypography.h3),
                Text(state.errorMessage ?? "Unknown error", style: AppTypography.body),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(TablerIcons.arrow_left, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        onPressed: () => context.goNamed('dashboard'),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Analytics", style: AppTypography.caption.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          Text(state.bikeId, style: AppTypography.h2.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          final currentState = context.read<DashboardBloc>().state;
                          if (currentState.bikeId.isNotEmpty) {
                            context.read<DashboardBloc>().add(DashboardLoadEvent(currentState.bikeId));
                          }
                        },
                        icon: const Icon(TablerIcons.refresh, size: 18),
                        label: const Text("Refresh"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          foregroundColor: Theme.of(context).colorScheme.onSurface,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Theme.of(context).dividerColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildActions(context, state),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCharts(state),
                      const SizedBox(height: 24),
                      _buildLogsList(context, state),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildCharts(DashboardState state) {
    // We need context here, but since it's a helper method, we should pass it or use a Builder.
    // However, since this is inside a class, we can't easily access context unless we pass it.
    // I'll wrap the return in a Builder to get context.
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        if (state.telemetry.isEmpty) {
          return Container(
            height: 300,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Text("No telemetry data available", style: AppTypography.body.copyWith(color: colorScheme.onSurface)),
          );
        }

        // Prepare data for charts
        final latencyLogs = state.telemetry
            .where((t) => t.type == 'API_LATENCY')
            .toList();
        
        latencyLogs.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        final List<MapEntry<DateTime, double>> chartData = latencyLogs
            .map((e) => MapEntry(e.timestamp, e.valPrimary.toDouble()))
            .toList();

        final sampledData = ChartUtils.downsampleTimeSeries(chartData, 100);

        return Container(
          height: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("API Latency (ms)", style: AppTypography.h4.copyWith(color: colorScheme.onSurface)),
              const SizedBox(height: 24),
              Expanded(
                child: SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  primaryXAxis: DateTimeAxis(
                    dateFormat: DateFormat.Hms(),
                    majorGridLines: const MajorGridLines(width: 0),
                    axisLine: const AxisLine(width: 0),
                    labelStyle: AppTypography.caption.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  primaryYAxis: NumericAxis(
                    majorGridLines:  MajorGridLines(width: 1, color: theme.dividerColor, dashArray: [5, 5]),
                    axisLine: const AxisLine(width: 0),
                    labelStyle: AppTypography.caption.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  series: <CartesianSeries>[
                    LineSeries<MapEntry<DateTime, double>, DateTime>(
                      dataSource: sampledData,
                      xValueMapper: (MapEntry<DateTime, double> data, _) => data.key,
                      yValueMapper: (MapEntry<DateTime, double> data, _) => data.value,
                      color: colorScheme.primary,
                      width: 2,
                    )
                  ],
                  tooltipBehavior: TooltipBehavior(enable: true),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildActions(BuildContext context, DashboardState state) {
    final theme = Theme.of(context);
    return PopupMenuButton<String>(
      icon: Icon(TablerIcons.dots_vertical, color: theme.colorScheme.onSurfaceVariant),
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: theme.dividerColor)),
      onSelected: (value) {
        if (value == 'delete_telemetry') {
          context.read<DashboardBloc>().add(DashboardDeleteTelemetryEvent(state.bikeId));
        } else if (value == 'delete_bike') {
          context.read<DashboardBloc>().add(DashboardDeleteBikeEvent(state.bikeId));
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'delete_telemetry',
          child: Row(
            children: [
              const Icon(TablerIcons.trash, size: 18, color: AppColors.warning),
              const SizedBox(width: 12),
              Text('Delete Telemetry', style: AppTypography.body.copyWith(color: theme.colorScheme.onSurface)),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete_bike',
          child: Row(
            children: [
              const Icon(TablerIcons.trash_x, size: 18, color: AppColors.error),
              const SizedBox(width: 12),
              Text('Delete Bike', style: AppTypography.body.copyWith(color: theme.colorScheme.onSurface)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogsList(BuildContext context, DashboardState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text("Recent Logs", style: AppTypography.h4.copyWith(color: colorScheme.onSurface)),
          ),
          Divider(height: 1, color: theme.dividerColor),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.telemetry.take(20).length,
            separatorBuilder: (context, index) => Divider(height: 1, color: theme.dividerColor),
            itemBuilder: (context, index) {
              final log = state.telemetry[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        log.type,
                        style: AppTypography.mono.copyWith(color: colorScheme.onSurface),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        log.valPrimary.toString(),
                        style: AppTypography.mono.copyWith(color: colorScheme.secondary),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        log.timestamp.toString(),
                        style: AppTypography.caption.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                    Text(
                      log.uuid.substring(0, 8),
                      style: AppTypography.caption.copyWith(color: theme.disabledColor),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
