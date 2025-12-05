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
import '../../data/models/analytics_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/chart_utils.dart';
import '../widgets/custom_error_widget.dart';

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
      child: _DetailsView(bikeId: bikeId),
    );
  }
}

class _DetailsView extends StatelessWidget {
  final String bikeId;

  const _DetailsView({required this.bikeId});

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
            child: CustomErrorWidget(
              message: state.errorMessage ?? "Unknown error",
              title: "Error loading data",
              onRetry: () {
                context.read<DashboardBloc>().add(DashboardLoadEvent(bikeId));
              },
            ),
          );
        }

        final analytics = state.analytics;
        if (analytics == null) {
          return const Center(child: Text("No analytics data available"));
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, state),
                const SizedBox(height: 32),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCards(context, analytics.summary),
                        const SizedBox(height: 24),
                        _buildChartsSection(context, analytics),
                        const SizedBox(height: 24),
                        _buildFailuresSection(context, analytics.failures),
                        const SizedBox(height: 24),
                        _buildApiStatsTable(context, analytics.apiStats),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, DashboardState state) {
    return Row(
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
                Text("Analytics Dashboard", style: AppTypography.caption.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
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

  Widget _buildSummaryCards(BuildContext context, AnalyticsSummary summary) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(context, "Total Calls", summary.totalCalls.toString(), TablerIcons.server, Colors.blue)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(context, "Success Rate", "${summary.successRate.toStringAsFixed(1)}%", TablerIcons.check, Colors.green)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(context, "Network Errors", "${summary.networkErrorRate.toStringAsFixed(1)}%", TablerIcons.wifi_off, Colors.red)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(context, "Server Errors", "${summary.serverErrorRate.toStringAsFixed(1)}%", TablerIcons.alert_triangle, Colors.orange)),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.caption.copyWith(color: theme.colorScheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: AppTypography.h3.copyWith(color: theme.colorScheme.onSurface)),
        ],
      ),
    );
  }

  Widget _buildChartsSection(BuildContext context, AnalyticsResponse analytics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(flex: 2, child: _buildLatencyChart(context, analytics.timeSeries)),
            const SizedBox(width: 24),
            Expanded(flex: 1, child: _buildConnectivityChart(context, analytics.connectivity)),
          ],
        ),
        const SizedBox(height: 24),
        _buildLatencyDistributionChart(context, analytics.apiStats),
      ],
    );
  }

  Widget _buildLatencyChart(BuildContext context, List<TimeSeriesPoint> timeSeries) {
    final theme = Theme.of(context);
    
    // Parse timestamps
    final data = timeSeries.map((e) {
      return MapEntry(DateTime.parse(e.timestamp), e.latency.toDouble());
    }).toList();
    
    // Sort by time
    data.sort((a, b) => a.key.compareTo(b.key));

    // Downsample if needed (e.g., max 100 points)
    final sampledData = ChartUtils.downsampleTimeSeries(data, 100);

    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Latency Over Time", style: AppTypography.h4.copyWith(color: theme.colorScheme.onSurface)),
          const SizedBox(height: 24),
          Expanded(
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: DateTimeAxis(
                dateFormat: DateFormat.Hms(),
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
              ),
              primaryYAxis: NumericAxis(
                majorGridLines: MajorGridLines(width: 1, color: theme.dividerColor, dashArray: [5, 5]),
                axisLine: const AxisLine(width: 0),
                title: AxisTitle(text: 'ms', textStyle: AppTypography.caption),
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <CartesianSeries>[
                LineSeries<MapEntry<DateTime, double>, DateTime>(
                  dataSource: sampledData,
                  xValueMapper: (MapEntry<DateTime, double> item, _) => item.key,
                  yValueMapper: (MapEntry<DateTime, double> item, _) => item.value,
                  color: theme.colorScheme.primary,
                  width: 2,
                  name: 'Latency',
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectivityChart(BuildContext context, ConnectivityStats connectivity) {
    final theme = Theme.of(context);
    final data = connectivity.stateDistribution.entries.toList();

    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Connectivity State", style: AppTypography.h4.copyWith(color: theme.colorScheme.onSurface)),
          const SizedBox(height: 24),
          Expanded(
            child: SfCircularChart(
              legend: Legend(isVisible: true, position: LegendPosition.bottom),
              series: <CircularSeries>[
                DoughnutSeries<MapEntry<String, int>, String>(
                  dataSource: data,
                  xValueMapper: (MapEntry<String, int> item, _) => item.key,
                  yValueMapper: (MapEntry<String, int> item, _) => item.value,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                  innerRadius: '60%',
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatencyDistributionChart(BuildContext context, List<APIStat> apiStats) {
    final theme = Theme.of(context);

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
          Text("API Latency Distribution (P99)", style: AppTypography.h4.copyWith(color: theme.colorScheme.onSurface)),
          const SizedBox(height: 24),
          Expanded(
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                labelRotation: -45,
              ),
              primaryYAxis: NumericAxis(
                majorGridLines: MajorGridLines(width: 1, color: theme.dividerColor, dashArray: [5, 5]),
                axisLine: const AxisLine(width: 0),
                title: AxisTitle(text: 'ms', textStyle: AppTypography.caption),
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <CartesianSeries>[
                ColumnSeries<APIStat, String>(
                  dataSource: apiStats,
                  xValueMapper: (APIStat stat, _) => stat.apiName,
                  yValueMapper: (APIStat stat, _) => stat.p99,
                  color: theme.colorScheme.secondary,
                  name: 'P99 Latency',
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailuresSection(BuildContext context, List<FailureIncident> failures) {
    final theme = Theme.of(context);
    
    if (failures.isEmpty) {
      return const SizedBox.shrink();
    }

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
            child: Text("Recent Failures & Incidents", style: AppTypography.h4.copyWith(color: AppColors.error)),
          ),
          Divider(height: 1, color: theme.dividerColor),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: failures.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: theme.dividerColor),
            itemBuilder: (context, index) {
              final failure = failures[index];
              return ListTile(
                leading: const Icon(TablerIcons.alert_circle, color: AppColors.error),
                title: Text(failure.apiName, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text("${failure.type} • Status: ${failure.statusCode} • Latency: ${failure.latency}ms", style: AppTypography.caption),
                trailing: Text(failure.timestamp, style: AppTypography.caption),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildApiStatsTable(BuildContext context, List<APIStat> apiStats) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
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
            child: Text("API Performance Statistics", style: AppTypography.h4.copyWith(color: theme.colorScheme.onSurface)),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text("API Name")),
                DataColumn(label: Text("Count"), numeric: true),
                DataColumn(label: Text("Mean (ms)"), numeric: true),
                DataColumn(label: Text("P99 (ms)"), numeric: true),
                DataColumn(label: Text("Max (ms)"), numeric: true),
                DataColumn(label: Text("Error Rate"), numeric: true),
              ],
              rows: apiStats.map((stat) {
                return DataRow(cells: [
                  DataCell(Text(stat.apiName, style: AppTypography.body)),
                  DataCell(Text(stat.count.toString(), style: AppTypography.mono)),
                  DataCell(Text(stat.mean.toStringAsFixed(0), style: AppTypography.mono)),
                  DataCell(Text(stat.p99.toStringAsFixed(0), style: AppTypography.mono)),
                  DataCell(Text(stat.max.toString(), style: AppTypography.mono)),
                  DataCell(Text("${stat.errorRate.toStringAsFixed(1)}%", 
                    style: AppTypography.mono.copyWith(
                      color: stat.errorRate > 0 ? AppColors.error : AppColors.success
                    )
                  )),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
