import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/theme.dart';

class ExecutionFailureCard extends StatelessWidget {
  final String failedStepName;
  final String errorMessage;
  final String errorCategory;
  final DateTime failureTime;
  final VoidCallback? onRetry;
  final VoidCallback? onAskAI;

  const ExecutionFailureCard({
    super.key,
    required this.failedStepName,
    required this.errorMessage,
    required this.errorCategory,
    required this.failureTime,
    this.onRetry,
    this.onAskAI,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm:ss');

    return Card(
      // ignore: deprecated_member_use
      color: AppColors.error.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppLayout.cardRadius),
        // ignore: deprecated_member_use
        side: BorderSide(color: AppColors.error.withOpacity(0.2)),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(AppLayout.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 24),
                const SizedBox(width: AppLayout.spaceS),
                Text(
                  'Execution Failed',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  timeFormat.format(failureTime),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppLayout.spaceM),
            _buildInfoRow(context, 'Failed Step', failedStepName),
            const SizedBox(height: AppLayout.spaceS),
            _buildInfoRow(context, 'Category', errorCategory),
            const SizedBox(height: AppLayout.spaceM),
            const Text(
              'ERROR MESSAGE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              errorMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppLayout.spaceL),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Retry Step'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: BorderSide(color: theme.colorScheme.outline),
                    ),
                  ),
                ),
                const SizedBox(width: AppLayout.spaceM),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onAskAI,
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: const Text('Ask Relay AI'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
