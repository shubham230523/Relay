import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/models/models.dart';

class RecentExecutionListItem extends StatelessWidget {
  final RecentExecution execution;

  const RecentExecutionListItem({
    super.key,
    required this.execution,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppLayout.spaceM),
        child: Row(
          children: [
            _StatusIcon(status: execution.status),
            const SizedBox(width: AppLayout.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    execution.automationName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppLayout.spaceXS),
                  Row(
                    children: [
                      Text(
                        'Started: Just now', // Simplified for mock
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppLayout.spaceS),
                      const Text('•'),
                      const SizedBox(width: AppLayout.spaceS),
                      Text(
                        'Duration: ${execution.duration.inSeconds}s',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppLayout.spaceM),
            _StatusLabel(status: execution.status),
          ],
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final ExecutionStatus status;

  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (status) {
      case ExecutionStatus.success:
        icon = Icons.check_circle;
        color = AppColors.success;
      case ExecutionStatus.failed:
        icon = Icons.error;
        color = AppColors.error;
      case ExecutionStatus.running:
        icon = Icons.sync;
        color = AppColors.info;
      case ExecutionStatus.pending:
        icon = Icons.schedule;
        color = AppColors.warning;
    }

    return Icon(icon, color: color, size: 24);
  }
}

class _StatusLabel extends StatelessWidget {
  final ExecutionStatus status;

  const _StatusLabel({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String label;
    Color color;

    switch (status) {
      case ExecutionStatus.success:
        label = 'Success';
        color = AppColors.success;
      case ExecutionStatus.failed:
        label = 'Failed';
        color = AppColors.error;
      case ExecutionStatus.running:
        label = 'Running';
        color = AppColors.info;
      case ExecutionStatus.pending:
        label = 'Pending';
        color = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.spaceS,
        vertical: AppLayout.spaceXS / 2,
      ),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppLayout.buttonRadius),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
