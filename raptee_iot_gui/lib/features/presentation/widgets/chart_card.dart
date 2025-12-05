import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  final double height;

  const ChartCard({
    super.key,
    required this.title,
    required this.child,
    this.height = 350,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: height,
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
