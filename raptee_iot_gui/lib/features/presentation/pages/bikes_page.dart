import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../data/models/bike_model.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/custom_error_widget.dart';

class BikesPage extends StatelessWidget {
  const BikesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _BikesView();
  }
}

class _BikesView extends StatefulWidget {
  const _BikesView();

  @override
  State<_BikesView> createState() => _BikesViewState();
}

class _BikesViewState extends State<_BikesView> {
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

  void _selectAll(bool? selected, List<BikeModel> bikes) {
    setState(() {
      if (selected == true) {
        _selectedBikeIds.addAll(bikes.map((b) => b.bikeId));
      } else {
        _selectedBikeIds.clear();
      }
    });
  }

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
          setState(() {
            _selectedBikeIds.clear();
          });
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
        final allSelected =
            bikes.isNotEmpty && _selectedBikeIds.length == bikes.length;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "All Bikes",
                    style: AppTypography.h2.copyWith(
                      color: colorScheme.onSurface,
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
                      if (_selectedBikeIds.isNotEmpty) ...[
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
                        const SizedBox(width: 16),
                      ],
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
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
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

              // List Container
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    children: [
                      // Table Header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40,
                              child: Checkbox(
                                value: allSelected,
                                onChanged: (val) => _selectAll(val, bikes),
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
                          ],
                        ),
                      ),
                      Divider(height: 1, color: theme.dividerColor),

                      // List Items
                      Expanded(
                        child: ListView.separated(
                          itemCount: bikes.length,
                          separatorBuilder: (context, index) =>
                              Divider(height: 1, color: theme.dividerColor),
                          itemBuilder: (context, index) {
                            final bike = bikes[index];
                            final isSelected = _selectedBikeIds.contains(
                              bike.bikeId,
                            );

                            return InkWell(
                              onTap: () {
                                context.goNamed(
                                  'details',
                                  pathParameters: {'bikeId': bike.bikeId},
                                );
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
                                        onChanged: (val) =>
                                            _toggleSelection(bike.bikeId),
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
                                        bike.metadata['model'] as String? ??
                                            '-',
                                        style: AppTypography.body.copyWith(
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        bike.metadata['color'] as String? ??
                                            '-',
                                        style: AppTypography.body.copyWith(
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
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
}
