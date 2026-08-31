import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/theme.dart';
import '../../../workflow_builder/domain/models/models.dart';
import '../../domain/models/models.dart';

class ExecutionTimeline extends StatelessWidget {
  final List<ExecutionStep> steps;

  const ExecutionTimeline({
    super.key,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          _TimelineStep(
            step: steps[i],
            isLast: i == steps.length - 1,
          ),
        ],
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final ExecutionStep step;
  final bool isLast;

  const _TimelineStep({
    required this.step,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    IconData icon;
    Color color;
    
    switch (step.status) {
      case ExecutionStepStatus.pending:
        icon = Icons.schedule;
        color = AppColors.textDisabled;
        break;
      case ExecutionStepStatus.running:
        icon = Icons.sync;
        color = AppColors.info;
        break;
      case ExecutionStepStatus.success:
        icon = Icons.check_circle;
        color = AppColors.success;
        break;
      case ExecutionStepStatus.failed:
        icon = Icons.error;
        color = AppColors.error;
        break;
      case ExecutionStepStatus.skipped:
        icon = Icons.skip_next;
        color = AppColors.textDisabled;
        break;
    }

    final duration = step.completedAt?.difference(step.startedAt);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Column
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppLayout.spaceM),
          // Content Column
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppLayout.spaceL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        step.nodeTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (duration != null)
                        Text(
                          '${duration.inSeconds}s',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      _NodeTypeChip(type: step.nodeType),
                      const SizedBox(width: AppLayout.spaceS),
                      Text(
                        step.status.name.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (step.errorMessage != null) ...[
                    const SizedBox(height: AppLayout.spaceS),
                    Text(
                      step.errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NodeTypeChip extends StatelessWidget {
  final WorkflowNodeType type;
  const _NodeTypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type.name.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 8,
          // ignore: deprecated_member_use
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
