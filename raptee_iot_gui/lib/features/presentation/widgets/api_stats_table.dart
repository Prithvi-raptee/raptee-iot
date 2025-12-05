import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../data/models/analytics_model.dart';

class ApiStatsTable extends StatelessWidget {
  final List<APIStat> apiStats;

  const ApiStatsTable({super.key, required this.apiStats});

  @override
  Widget build(BuildContext context) {
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
            child: Text(
              "API Performance Statistics",
              style: AppTypography.h4.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
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
                return DataRow(
                  cells: [
                    DataCell(Text(stat.apiName, style: AppTypography.body)),
                    DataCell(
                      Text(stat.count.toString(), style: AppTypography.mono),
                    ),
                    DataCell(
                      Text(
                        stat.mean.toStringAsFixed(0),
                        style: AppTypography.mono,
                      ),
                    ),
                    DataCell(
                      Text(
                        stat.p99.toStringAsFixed(0),
                        style: AppTypography.mono,
                      ),
                    ),
                    DataCell(
                      Text(stat.max.toString(), style: AppTypography.mono),
                    ),
                    DataCell(
                      Text(
                        "${stat.errorRate.toStringAsFixed(1)}%",
                        style: AppTypography.mono.copyWith(
                          color: stat.errorRate > 0
                              ? AppColors.error
                              : AppColors.success,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
