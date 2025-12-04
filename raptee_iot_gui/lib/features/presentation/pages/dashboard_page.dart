import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/custom_error_widget.dart';
import '../../data/models/bike_model.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DashboardAnalyticsView();
  }
}

class _DashboardAnalyticsView extends StatelessWidget {
  const _DashboardAnalyticsView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardBloc, DashboardState>(
      listenWhen: (previous, current) =>
          previous.deleteStatus != current.deleteStatus,
      listener: (context, state) {
        if (state.deleteStatus == DeleteStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Operation completed successfully",
                style: AppTypography.body.copyWith(color: Colors.white),
              ),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state.deleteStatus == DeleteStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ?? "Operation failed",
                style: AppTypography.body.copyWith(color: Colors.white),
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
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

        final bikes = state.bikes;
        final totalBikes = bikes.length;
        final modelData = _getModelData(bikes);
        final colorData = _getColorData(bikes);
        final registrationData = _getRegistrationData(bikes);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Dashboard Overview",
                style: AppTypography.h2.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),

              // Key Metrics Row
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: "Total Bikes",
                      value: totalBikes.toString(),
                      icon: TablerIcons.motorbike,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _MetricCard(
                      title: "Active Models",
                      value: modelData.length.toString(),
                      icon: TablerIcons.chart_pie,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _MetricCard(
                      title: "Colors",
                      value: colorData.length.toString(),
                      icon: TablerIcons.palette,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Charts Row 1: Models and Colors
              Row(
                children: [
                  Expanded(
                    child: _ChartCard(
                      title: "Model Distribution",
                      child: SfCircularChart(
                        legend: Legend(
                          isVisible: true,
                          position: LegendPosition.bottom,
                        ),
                        series: <CircularSeries>[
                          DoughnutSeries<_ChartData, String>(
                            dataSource: modelData,
                            xValueMapper: (_ChartData data, _) => data.x,
                            yValueMapper: (_ChartData data, _) => data.y,
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _ChartCard(
                      title: "Color Distribution",
                      child: SfCircularChart(
                        legend: Legend(
                          isVisible: true,
                          position: LegendPosition.bottom,
                        ),
                        series: <CircularSeries>[
                          PieSeries<_ChartData, String>(
                            dataSource: colorData,
                            xValueMapper: (_ChartData data, _) => data.x,
                            yValueMapper: (_ChartData data, _) => data.y,
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Charts Row 2: Registration Trends
              _ChartCard(
                title: "Registration Trends",
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  primaryYAxis: NumericAxis(
                    title: AxisTitle(text: 'Bikes Registered'),
                  ),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <CartesianSeries>[
                    ColumnSeries<_ChartData, String>(
                      name: 'Registrations',
                      dataSource: registrationData,
                      xValueMapper: (_ChartData data, _) => data.x,
                      yValueMapper: (_ChartData data, _) => data.y,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Bike List moved to Bikes Page

            ],
          ),
        );
      },
    );
  }

  List<_ChartData> _getModelData(List<BikeModel> bikes) {
    final Map<String, int> counts = {};
    for (var bike in bikes) {
      final model = bike.metadata['model'] as String? ?? 'Unknown';
      counts[model] = (counts[model] ?? 0) + 1;
    }
    return counts.entries.map((e) => _ChartData(e.key, e.value)).toList();
  }

  List<_ChartData> _getColorData(List<BikeModel> bikes) {
    final Map<String, int> counts = {};
    for (var bike in bikes) {
      final color = bike.metadata['color'] as String? ?? 'Unknown';
      counts[color] = (counts[color] ?? 0) + 1;
    }
    return counts.entries.map((e) => _ChartData(e.key, e.value)).toList();
  }

  List<_ChartData> _getRegistrationData(List<BikeModel> bikes) {
    final Map<String, int> counts = {};
    for (var bike in bikes) {
      // Assuming 'registration_date' or similar exists, else use 'Unknown' or skip
      // Format: YYYY-MM-DD
      final dateStr =
          bike.metadata['registration_date'] as String? ??
          bike.metadata['date'] as String? ??
          'Unknown';

      // If date is ISO string, maybe parse and format to Month/Year
      String label = dateStr;
      try {
        if (dateStr != 'Unknown') {
          final date = DateTime.parse(dateStr);
          label = DateFormat('MMM yyyy').format(date);
        }
      } catch (e) {
        // ignore parse error
      }

      counts[label] = (counts[label] ?? 0) + 1;
    }

    // Sort by date if possible, but for now just return list
    return counts.entries.map((e) => _ChartData(e.key, e.value)).toList();
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.caption.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTypography.h2.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 350,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.h3.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);
  final String x;
  final int y;
}


