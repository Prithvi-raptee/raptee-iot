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
import 'dart:math' as math;

class DetailsPage extends StatelessWidget {
  final String bikeId;

  const DetailsPage({super.key, required this.bikeId});

  @override
  Widget build(BuildContext context) {
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

class _DetailsView extends StatefulWidget {
  final String bikeId;

  const _DetailsView({required this.bikeId});

  @override
  State<_DetailsView> createState() => _DetailsViewState();
}

class _DetailsViewState extends State<_DetailsView> {
  bool _showSuccessOnly = true;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardBloc, DashboardState>(
      listener: (context, state) {
        if (state.deleteStatus == DeleteStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Operation Successful"), backgroundColor: AppColors.success),
          );
          context.goNamed('dashboard');
        } else if (state.deleteStatus == DeleteStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? "Operation Failed"), backgroundColor: AppColors.error),
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
              onRetry: () => context.read<DashboardBloc>().add(DashboardLoadEvent(widget.bikeId)),
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
                const SizedBox(height: 24),
                _buildToggle(),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCards(context, analytics.summary),
                        const SizedBox(height: 32),
                        
                        _buildSectionTitle("Failure & High Latency Analysis"),
                        _buildFailureAnalysis(context, analytics.failures),
                        const SizedBox(height: 32),

                        _buildSectionTitle("Latency Percentiles (Success Only)"),
                        _buildPercentilesChart(context, analytics.apiStats),
                        const SizedBox(height: 32),

                        _buildSectionTitle("Cellular Connectivity Overview"),
                        _buildConnectivityOverview(context, analytics.connectivity),
                        const SizedBox(height: 32),

                        _buildSectionTitle("Cellular Signal & Latency"),
                        _buildSignalAnalysis(context, analytics.timeSeries, analytics.connectivity),
                        const SizedBox(height: 32),

                        _buildSectionTitle("General API Analysis (${_showSuccessOnly ? 'Success Only' : 'All Data'})"),
                        _buildGeneralApiAnalysis(context, analytics.timeSeries),
                        const SizedBox(height: 32),

                        _buildSectionTitle("API Performance Statistics"),
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

  Widget _buildToggle() {
    return Row(
      children: [
        Text("View Mode: ", style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(width: 12),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment<bool>(value: false, label: Text("All Data")),
            ButtonSegment<bool>(value: true, label: Text("Success Only")),
          ],
          selected: {_showSuccessOnly},
          onSelectionChanged: (Set<bool> newSelection) {
            setState(() {
              _showSuccessOnly = newSelection.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: AppTypography.h3.copyWith(color: Theme.of(context).colorScheme.primary)),
    );
  }

  // --- 1. Failure Analysis ---
  Widget _buildFailureAnalysis(BuildContext context, List<FailureIncident> failures) {
    if (failures.isEmpty) return const Text("No failures recorded.");
    
    // Incident Count per API
    final Map<String, int> counts = {};
    for (var f in failures) {
      counts[f.apiName] = (counts[f.apiName] ?? 0) + 1;
    }
    final countData = counts.entries.map((e) => _ChartData(e.key, e.value)).toList();

    // Prepare Y-Axis Categories for Scatter Plot
    final uniqueApis = failures.map((e) => e.apiName).toSet().toList();
    uniqueApis.sort();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildChartContainer(context, "Incident Count per API", 
                SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  series: <CartesianSeries>[
                    BarSeries<_ChartData, String>(
                      dataSource: countData,
                      xValueMapper: (_ChartData data, _) => data.x,
                      yValueMapper: (_ChartData data, _) => data.y,
                      color: AppColors.error,
                      dataLabelSettings: const DataLabelSettings(isVisible: true),
                    )
                  ],
                )
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildChartContainer(context, "Incident Timeline", 
                SfCartesianChart(
                  primaryXAxis: DateTimeAxis(dateFormat: DateFormat.Hm()),
                  primaryYAxis: NumericAxis(
                    interval: 1,
                    minimum: -0.5,
                    maximum: uniqueApis.length - 0.5,
                    axisLabelFormatter: (AxisLabelRenderDetails args) {
                      final index = args.value.round();
                      if (index >= 0 && index < uniqueApis.length) {
                        return ChartAxisLabel(uniqueApis[index], args.textStyle);
                      }
                      return ChartAxisLabel('', args.textStyle);
                    },
                  ),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <CartesianSeries>[
                    ScatterSeries<FailureIncident, DateTime>(
                      dataSource: failures,
                      xValueMapper: (FailureIncident f, _) => DateTime.parse(f.timestamp),
                      yValueMapper: (FailureIncident f, _) => uniqueApis.indexOf(f.apiName),
                      pointColorMapper: (FailureIncident f, _) {
                        if (f.type.contains("Network")) return Colors.red;
                        if (f.type.contains("Server")) return Colors.orange;
                        if (f.type.contains("High Latency")) return Colors.purple;
                        return Colors.grey;
                      },
                      name: 'Incidents',
                    )
                  ],
                )
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- 2. Percentiles ---
  Widget _buildPercentilesChart(BuildContext context, List<APIStat> stats) {
    return _buildChartContainer(context, "Latency Percentiles (ms)", 
      SfCartesianChart(
        primaryXAxis: CategoryAxis(labelRotation: -45),
        legend: Legend(isVisible: true, position: LegendPosition.bottom),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries>[
          ColumnSeries<APIStat, String>(dataSource: stats, xValueMapper: (s, _) => s.apiName, yValueMapper: (s, _) => s.p50, name: 'P50'),
          ColumnSeries<APIStat, String>(dataSource: stats, xValueMapper: (s, _) => s.apiName, yValueMapper: (s, _) => s.p90, name: 'P90'),
          ColumnSeries<APIStat, String>(dataSource: stats, xValueMapper: (s, _) => s.apiName, yValueMapper: (s, _) => s.p95, name: 'P95'),
          ColumnSeries<APIStat, String>(dataSource: stats, xValueMapper: (s, _) => s.apiName, yValueMapper: (s, _) => s.p99, name: 'P99'),
        ],
      )
    );
  }

  // --- 3. Connectivity Overview ---
  Widget _buildConnectivityOverview(BuildContext context, ConnectivityStats stats) {
    final failureData = stats.failureRateByState.entries.map((e) => _ChartData(e.key, e.value)).toList();
    
    // Box Plot Data Preparation
    // Syncfusion BoxAndWhiskerSeries needs a list of objects, and xValueMapper/yValueMapper (list of values)
    final List<_BoxPlotData> boxData = stats.latencyByState.entries.map((e) {
      return _BoxPlotData(e.key, e.value.map((v) => v.toDouble()).toList());
    }).toList();

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: _buildStatCardTable(context, "State Statistics", stats.stateDistribution),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _buildChartContainer(context, "Connection State Distribution", 
                SfCircularChart(
                  legend: Legend(isVisible: true),
                  series: <CircularSeries>[
                    DoughnutSeries<MapEntry<String, int>, String>(
                      dataSource: stats.stateDistribution.entries.toList(),
                      xValueMapper: (e, _) => e.key,
                      yValueMapper: (e, _) => e.value,
                      dataLabelSettings: const DataLabelSettings(isVisible: true),
                    )
                  ],
                )
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildChartContainer(context, "Failure Rate by State (%)", 
                SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  series: <CartesianSeries>[
                    BarSeries<_ChartData, String>(
                      dataSource: failureData,
                      xValueMapper: (d, _) => d.x,
                      yValueMapper: (d, _) => d.y,
                      color: AppColors.error,
                      dataLabelSettings: const DataLabelSettings(isVisible: true, labelPosition: ChartDataLabelPosition.outside),
                    )
                  ],
                )
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildChartContainer(context, "Latency Dist by State", 
                SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  primaryYAxis: NumericAxis(title: AxisTitle(text: 'ms')),
                  series: <CartesianSeries>[
                    BoxAndWhiskerSeries<_BoxPlotData, String>(
                      dataSource: boxData,
                      xValueMapper: (d, _) => d.x,
                      yValueMapper: (d, _) => d.y,
                      boxPlotMode: BoxPlotMode.normal,
                    )
                  ],
                )
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- 4. Signal Analysis ---
  Widget _buildSignalAnalysis(BuildContext context, List<TimeSeriesPoint> timeSeries, ConnectivityStats connStats) {
    final validSignal = timeSeries.where((t) => t.signalStrength > 0).toList();
    
    return _buildChartContainer(context, "Signal Strength vs Latency", 
      SfCartesianChart(
        primaryXAxis: NumericAxis(title: AxisTitle(text: 'Signal Strength (%)')),
        primaryYAxis: NumericAxis(title: AxisTitle(text: 'Latency (ms)')),
        legend: Legend(isVisible: true),
        series: <CartesianSeries>[
          ScatterSeries<TimeSeriesPoint, int>(
            dataSource: validSignal,
            xValueMapper: (t, _) => t.signalStrength,
            yValueMapper: (t, _) => t.latency,
            pointColorMapper: (t, _) => t.connectionState == 'WiFi' ? Colors.blue : Colors.green,
            name: 'Calls',
          )
        ],
      )
    );
  }

  // --- 5. General API Analysis (Dynamic) ---
  Widget _buildGeneralApiAnalysis(BuildContext context, List<TimeSeriesPoint> rawData) {
    // Filter Data
    final data = _showSuccessOnly ? rawData.where((t) => t.status == 200).toList() : rawData;
    
    // 1. Latency Distribution (Box Plot)
    final Map<String, List<double>> apiLatencies = {};
    for (var t in data) {
      if (!apiLatencies.containsKey(t.apiName)) apiLatencies[t.apiName] = [];
      apiLatencies[t.apiName]!.add(t.latency.toDouble());
    }
    final boxData = apiLatencies.entries.map((e) => _BoxPlotData(e.key, e.value)).toList();

    // 2. Latency Over Time
    // Downsample for performance
    final sortedData = List<TimeSeriesPoint>.from(data)..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final timeData = sortedData.map((e) => MapEntry(DateTime.parse(e.timestamp), e.latency.toDouble())).toList();
    final sampledTimeData = ChartUtils.downsampleTimeSeries(timeData, 150);

    // 3. Average Latency
    final avgData = apiLatencies.entries.map((e) {
      final avg = e.value.reduce((a, b) => a + b) / e.value.length;
      return _ChartData(e.key, avg);
    }).toList();

    // 4. Status Code Distribution
    final Map<String, Map<int, int>> statusDist = {};
    for (var t in rawData) { // Always show all status codes for distribution context? Or filter? User asked for toggle effect.
       // If toggle is "Success Only", status dist is boring (100% 200). 
       // So for Status Dist, maybe we should ALWAYS show all, or respect toggle.
       // User said "API Call Status Code Distribution" in the list.
       // If I respect toggle, and toggle is success only, it's just one bar.
       // I'll respect the toggle for consistency, but it might be empty if filtered.
       // Actually, let's use rawData for Status Dist if user wants to see errors.
       // But wait, "General API Analysis (Affected by Toggle)".
       // I will use `data` (filtered).
       if (!statusDist.containsKey(t.apiName)) statusDist[t.apiName] = {};
       statusDist[t.apiName]![t.status] = (statusDist[t.apiName]![t.status] ?? 0) + 1;
    }
    
    // Prepare Stacked Data is complex with dynamic status codes. 
    // Simplified: Grouped Bar of Status Codes? Or just a simple count plot?
    // Let's do a simple Stacked Column 100% if possible, or just a table/chart.
    // For simplicity and robustness: StackedColumnSeries for common codes (200, 0, 500, 400, others).
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildChartContainer(context, "Latency Distribution", 
                SfCartesianChart(
                  primaryXAxis: CategoryAxis(labelRotation: -45),
                  primaryYAxis: NumericAxis(title: AxisTitle(text: 'ms')),
                  series: <CartesianSeries>[
                    BoxAndWhiskerSeries<_BoxPlotData, String>(
                      dataSource: boxData,
                      xValueMapper: (d, _) => d.x,
                      yValueMapper: (d, _) => d.y,
                      boxPlotMode: BoxPlotMode.normal,
                    )
                  ],
                )
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildChartContainer(context, "Latency Over Time", 
                SfCartesianChart(
                  primaryXAxis: DateTimeAxis(dateFormat: DateFormat.Hms()),
                  primaryYAxis: NumericAxis(title: AxisTitle(text: 'ms')),
                  series: <CartesianSeries>[
                    LineSeries<MapEntry<DateTime, double>, DateTime>(
                      dataSource: sampledTimeData,
                      xValueMapper: (d, _) => d.key,
                      yValueMapper: (d, _) => d.value,
                      name: 'Latency',
                    )
                  ],
                )
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildChartContainer(context, "Average Latency", 
                SfCartesianChart(
                  primaryXAxis: CategoryAxis(labelRotation: -45),
                  series: <CartesianSeries>[
                    ColumnSeries<_ChartData, String>(
                      dataSource: avgData,
                      xValueMapper: (d, _) => d.x,
                      yValueMapper: (d, _) => d.y,
                      dataLabelSettings: const DataLabelSettings(isVisible: true),
                    )
                  ],
                )
              ),
            ),
            const SizedBox(width: 16),
             Expanded(
              child: _buildChartContainer(context, "Status Code Dist (All Data)", 
                SfCartesianChart(
                  primaryXAxis: CategoryAxis(labelRotation: -45),
                  legend: Legend(isVisible: true),
                  series: _buildStatusSeries(rawData), // Always show all for status dist
                )
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<CartesianSeries> _buildStatusSeries(List<TimeSeriesPoint> data) {
    // Group by API and Status
    final Map<String, Map<int, int>> counts = {};
    final Set<int> allStatuses = {};
    
    for (var t in data) {
      if (!counts.containsKey(t.apiName)) counts[t.apiName] = {};
      counts[t.apiName]![t.status] = (counts[t.apiName]![t.status] ?? 0) + 1;
      allStatuses.add(t.status);
    }

    final List<String> apis = counts.keys.toList();
    final List<CartesianSeries> series = [];

    for (var status in allStatuses) {
      final List<_ChartData> statusData = [];
      for (var api in apis) {
        statusData.add(_ChartData(api, (counts[api]![status] ?? 0).toDouble()));
      }
      
      series.add(
        StackedColumnSeries<_ChartData, String>(
          dataSource: statusData,
          xValueMapper: (d, _) => d.x,
          yValueMapper: (d, _) => d.y,
          name: status.toString(),
        )
      );
    }
    return series;
  }

  // --- Helpers ---

  Widget _buildChartContainer(BuildContext context, String title, Widget chart) {
    final theme = Theme.of(context);
    return Container(
      height: 350,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.h4.copyWith(color: theme.colorScheme.onSurface)),
          const SizedBox(height: 16),
          Expanded(child: chart),
        ],
      ),
    );
  }

  Widget _buildStatCardTable(BuildContext context, String title, Map<String, int> data) {
    final theme = Theme.of(context);
    return Container(
      height: 350,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.h4.copyWith(color: theme.colorScheme.onSurface)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: data.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: theme.dividerColor),
              itemBuilder: (context, index) {
                final key = data.keys.elementAt(index);
                final value = data.values.elementAt(index);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(key, style: AppTypography.body),
                      Text(value.toString(), style: AppTypography.mono.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
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

class _ChartData {
  final dynamic x;
  final dynamic y;
  _ChartData(this.x, this.y);
}

class _BoxPlotData {
  final dynamic x;
  final List<double> y;
  _BoxPlotData(this.x, this.y);
}
