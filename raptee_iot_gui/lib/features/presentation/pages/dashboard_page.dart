import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/chart_utils.dart';
import '../../data/models/telemetry_model.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dependency Injection (Simple version for this scope)
    final apiClient = ApiClient();
    final dataSource = DashboardRemoteDataSourceImpl(apiClient: apiClient);
    final repository = DashboardRepository(remoteDataSource: dataSource);

    return BlocProvider(
      create: (context) => DashboardBloc(repository: repository)
        ..add(const DashboardLoadEvent("TEST_BIKE_001")), // Default ID for now
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fleet Overview"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final state = context.read<DashboardBloc>().state;
              if (state.bikeId.isNotEmpty) {
                context.read<DashboardBloc>().add(DashboardLoadEvent(state.bikeId));
              }
            },
          )
        ],
      ),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state.deleteStatus == DeleteStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Operation Successful")),
            );
          } else if (state.deleteStatus == DeleteStatus.failure) {
            print(state.errorMessage);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? "Operation Failed")),
            );
          }
        },
        builder: (context, state) {
          if (state.status == DashboardStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == DashboardStatus.failure) {
            print(state.errorMessage);
            return Center(child: Text("Error: ${state.errorMessage}"));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, state),
                const SizedBox(height: 20),
                _buildCharts(state),
                const SizedBox(height: 20),
                _buildActions(context, state),
                const SizedBox(height: 20),
                _buildLogsList(state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DashboardState state) {
    // Note: In a real app, use a TextEditingController managed by the widget state or Bloc
    // For simplicity here, we create one, but it might reset on rebuilds. 
    // Ideally, convert _DashboardView to StatefulWidget or keep controller in Bloc.
    // For this fix, let's use a local controller but initialize it with state.bikeId
    final TextEditingController controller = TextEditingController(text: state.bikeId);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: "Bike ID",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        context.read<DashboardBloc>().add(DashboardLoadEvent(value));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      context.read<DashboardBloc>().add(DashboardLoadEvent(controller.text));
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text("Total Logs: ${state.telemetry.length}", style: AppTypography.body),
          ],
        ),
      ),
    );
  }

  Widget _buildCharts(DashboardState state) {
    if (state.telemetry.isEmpty) return const SizedBox();

    // Prepare data for charts
    // Filter for Latency logs
    final latencyLogs = state.telemetry
        .where((t) => t.type == 'API_LATENCY')
        .toList();
    
    // Sort by timestamp
    latencyLogs.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Convert to Chart Data Points
    final List<MapEntry<DateTime, double>> chartData = latencyLogs
        .map((e) => MapEntry(e.timestamp, e.valPrimary.toDouble()))
        .toList();

    // Downsample if needed
    final sampledData = ChartUtils.downsampleTimeSeries(chartData, 100);

    return SizedBox(
      height: 300,
      child: SfCartesianChart(
        title: ChartTitle(text: 'API Latency (ms)'),
        primaryXAxis: DateTimeAxis(
          dateFormat: DateFormat.Hms(),
        ),
        primaryYAxis: NumericAxis(),
        series: <CartesianSeries>[
          LineSeries<MapEntry<DateTime, double>, DateTime>(
            dataSource: sampledData,
            xValueMapper: (MapEntry<DateTime, double> data, _) => data.key,
            yValueMapper: (MapEntry<DateTime, double> data, _) => data.value,
            color: AppColors.primary,
          )
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, DashboardState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () {
             context.read<DashboardBloc>().add(DashboardDeleteTelemetryEvent(state.bikeId));
          },
          icon: const Icon(Icons.delete_sweep),
          label: const Text("Delete Telemetry"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        ),
        ElevatedButton.icon(
          onPressed: () {
            context.read<DashboardBloc>().add(DashboardDeleteBikeEvent(state.bikeId));
          },
          icon: const Icon(Icons.delete_forever),
          label: const Text("Delete Bike"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
      ],
    );
  }

  Widget _buildLogsList(DashboardState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Recent Logs", style: AppTypography.h3),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.telemetry.take(20).length, // Show last 20
          itemBuilder: (context, index) {
            final log = state.telemetry[index];
            return ListTile(
              title: Text("${log.type} - ${log.valPrimary}"),
              subtitle: Text(log.timestamp.toString()),
              trailing: Text(log.uuid.substring(0, 8)),
            );
          },
        ),
      ],
    );
  }
}