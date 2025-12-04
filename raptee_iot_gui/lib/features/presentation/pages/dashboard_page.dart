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
import '../../data/repositories/dashboard_repository.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';
import '../../../core/network/api_client.dart';
import '../widgets/custom_error_widget.dart';
import '../../data/models/bike_model.dart';
import '../../../core/widgets/confirmation_dialog.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final DashboardRepository _repository;

  @override
  void initState() {
    super.initState();
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
      child: const _DashboardAnalyticsView(),
    );
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

              // Bike List with Bulk Actions
              _BikeListSection(bikes: bikes),
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

class _BikeListSection extends StatefulWidget {
  final List<BikeModel> bikes;

  const _BikeListSection({required this.bikes});

  @override
  State<_BikeListSection> createState() => _BikeListSectionState();
}

class _BikeListSectionState extends State<_BikeListSection> {
  final Set<String> _selectedBikeIds = {};

  void _toggleSelection(String bikeId) {
    setState(() {
      if (_selectedBikeIds.contains(bikeId)) {
        _selectedBikeIds.remove(bikeId);
      } else {
        _selectedBikeIds.add(bikeId);
      }
    });
  }

  void _selectAll(bool? selected) {
    setState(() {
      if (selected == true) {
        _selectedBikeIds.addAll(widget.bikes.map((b) => b.bikeId));
      } else {
        _selectedBikeIds.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final allSelected =
        widget.bikes.isNotEmpty &&
        _selectedBikeIds.length == widget.bikes.length;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Actions
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "All Bikes",
                  style: AppTypography.h3.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                if (_selectedBikeIds.isNotEmpty)
                  Row(
                    children: [
                      Text(
                        "${_selectedBikeIds.length} selected",
                        style: AppTypography.body.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 16),
                      PopupMenuButton<String>(
                        icon: Icon(
                          TablerIcons.dots_vertical,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        color: theme.colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: theme.dividerColor),
                        ),
                        onSelected: (value) {
                          if (value == 'delete_telemetry') {
                            ConfirmationDialog.show(
                              context: context,
                              title: 'Delete Telemetry',
                              content:
                                  'Are you sure you want to delete telemetry for ${_selectedBikeIds.length} bikes?',
                              confirmText: 'Delete',
                              isDangerous: true,
                              onConfirm: () {
                                context.read<DashboardBloc>().add(
                                  DashboardDeleteTelemetryBulkEvent(
                                    _selectedBikeIds.toList(),
                                  ),
                                );
                                setState(() => _selectedBikeIds.clear());
                              },
                            );
                          } else if (value == 'delete_bikes') {
                            ConfirmationDialog.show(
                              context: context,
                              title: 'Delete Bikes',
                              content:
                                  'Are you sure you want to delete ${_selectedBikeIds.length} bikes?',
                              confirmText: 'Delete',
                              isDangerous: true,
                              onConfirm: () {
                                context.read<DashboardBloc>().add(
                                  DashboardDeleteBikesEvent(
                                    _selectedBikeIds.toList(),
                                  ),
                                );
                                setState(() => _selectedBikeIds.clear());
                              },
                            );
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'delete_telemetry',
                                child: Row(
                                  children: [
                                    const Icon(
                                      TablerIcons.trash,
                                      size: 18,
                                      color: AppColors.warning,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Delete Telemetry',
                                      style: AppTypography.body.copyWith(
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete_bikes',
                                child: Row(
                                  children: [
                                    const Icon(
                                      TablerIcons.trash_x,
                                      size: 18,
                                      color: AppColors.error,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Delete Bikes',
                                      style: AppTypography.body.copyWith(
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.dividerColor),

          // Table Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Checkbox(
                    value: allSelected,
                    onChanged: (val) => _selectAll(val),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    "Bike ID",
                    style: AppTypography.caption.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "Model",
                    style: AppTypography.caption.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "Color",
                    style: AppTypography.caption.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "Last Seen",
                    style: AppTypography.caption.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.dividerColor),

          // List Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.bikes.length,
            separatorBuilder: (context, index) =>
                Divider(height: 1, color: theme.dividerColor),
            itemBuilder: (context, index) {
              final bike = widget.bikes[index];
              final isSelected = _selectedBikeIds.contains(bike.bikeId);

              return InkWell(
                onTap: () {
                  // Navigate to details on row tap, or toggle selection?
                  // Let's toggle selection on checkbox, navigate on row tap?
                  // Or simple row tap toggles selection for bulk actions?
                  // Usually row tap navigates. Checkbox selects.
                  // But let's make row tap navigate to details.
                  // We need GoRouter here.
                  // context.goNamed('details', pathParameters: {'id': bike.bikeId});
                  // But I don't have GoRouter imported in this snippet context maybe?
                  // It is imported in the file.
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Checkbox(
                          value: isSelected,
                          onChanged: (val) => _toggleSelection(bike.bikeId),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          bike.bikeId,
                          style: AppTypography.body.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          bike.metadata['model'] as String? ?? '-',
                          style: AppTypography.body.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          bike.metadata['color'] as String? ?? '-',
                          style: AppTypography.body.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      // Expanded(
                      //   flex: 2,
                      //   child: Text(
                      //     _formatDate(bike.lastSeenAt),
                      //     style: AppTypography.caption.copyWith(color: colorScheme.onSurfaceVariant),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Never";
    return DateFormat.yMMMd().add_jm().format(date);
  }
}
