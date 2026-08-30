import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/models/models.dart';

class WorkflowStepCard extends StatelessWidget {
  final int stepNumber;
  final WorkflowNode node;

  const WorkflowStepCard({
    super.key,
    required this.stepNumber,
    required this.node,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    IconData icon;
    Color color;
    String typeLabel;
    
    switch (node.type) {
      case WorkflowNodeType.trigger:
        icon = Icons.bolt;
        color = AppColors.primary;
        typeLabel = 'TRIGGER';
        break;
      case WorkflowNodeType.ai:
        icon = Icons.psychology;
        color = AppColors.secondary;
        typeLabel = 'AI STEP';
        break;
      case WorkflowNodeType.logic:
        icon = Icons.account_tree;
        color = AppColors.warning;
        typeLabel = 'LOGIC';
        break;
      case WorkflowNodeType.action:
        icon = Icons.settings_input_component;
        color = AppColors.success;
        typeLabel = 'ACTION';
        break;
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppLayout.cardRadius),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppLayout.spaceM),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 18,
                  // ignore: deprecated_member_use
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: AppLayout.spaceXS),
                Text(
                  '#$stepNumber',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppLayout.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        typeLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppLayout.spaceXS),
                  Text(
                    node.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppLayout.spaceXS),
                  Text(
                    node.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
