import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/models/models.dart';
import 'execution_status_badge.dart';

class ExecutionListItem extends StatelessWidget {
  final Execution execution;

  const ExecutionListItem({
    super.key,
    required this.execution,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('MMM dd, HH:mm');

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.push(AppRoutes.executionDetails.replaceFirst(':id', execution.id)),
        borderRadius: BorderRadius.circular(AppLayout.cardRadius),
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
                          timeFormat.format(execution.startedAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (execution.duration != null) ...[
                          const SizedBox(width: AppLayout.spaceS),
                          const Text('•'),
                          const SizedBox(width: AppLayout.spaceS),
                          Text(
                            '${execution.duration!.inSeconds}s',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppLayout.spaceM),
              ExecutionStatusBadge(status: execution.status),
            ],
          ),
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
      case ExecutionStatus.cancelled:
        icon = Icons.cancel;
        color = AppColors.textDisabled;
    }

    return Icon(icon, color: color, size: 24);
  }
}
