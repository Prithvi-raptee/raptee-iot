import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? title;

  const CustomErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Illustration
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                // If dark mode, add a subtle light background or glow to make the white image pop nicely
                // or just let it be if it looks good. Given it's a white BG image:
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.transparent,
              ),
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/error_illustration.png',
                  height: 200,
                  fit: BoxFit.contain,
                  // If the image is simple black/white line art, we could use colorBlendMode
                  // But user said "cat chewing wire", likely full color or specific art.
                  // We'll trust the container to frame it.
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Title
            Text(
              title ?? 'Oops! Something went wrong',
              style: AppTypography.h3.copyWith(color: theme.colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: AppTypography.body.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Retry Button
            if (onRetry != null)
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
