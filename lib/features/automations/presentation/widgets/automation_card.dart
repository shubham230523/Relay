import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/models/models.dart';

class AutomationCard extends StatelessWidget {
  final Automation automation;

  const AutomationCard({
    super.key,
    required this.automation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppLayout.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppLayout.spaceS),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppLayout.buttonRadius),
                  ),
                  child: const Icon(
                    Icons.bolt, // Trigger type icon placeholder
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppLayout.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        automation.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppLayout.spaceXS),
                      Text(
                        automation.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppLayout.spaceM),
                _StatusBadge(status: automation.status),
              ],
            ),
            const SizedBox(height: AppLayout.spaceM),
            const Divider(),
            const SizedBox(height: AppLayout.spaceS),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  automation.lastExecutedAt != null
                      ? 'Last executed: 2 hours ago' // Mock time formatting
                      : 'Never executed',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Workflow ID: ${automation.id}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AutomationStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color color;
    String label;

    switch (status) {
      case AutomationStatus.active:
        color = AppColors.success;
        label = 'Active';
        break;
      case AutomationStatus.paused:
        color = AppColors.textDisabled;
        label = 'Paused';
        break;
      case AutomationStatus.draft:
        color = AppColors.info;
        label = 'Draft';
        break;
      case AutomationStatus.error:
        color = AppColors.error;
        label = 'Error';
        break;
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
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.2)),
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
