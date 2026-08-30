import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/models/models.dart';

class ExecutionStatusBadge extends StatelessWidget {
  final ExecutionStatus status;

  const ExecutionStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color color;
    String label;

    switch (status) {
      case ExecutionStatus.pending:
        color = AppColors.warning;
        label = 'Pending';
        break;
      case ExecutionStatus.running:
        color = AppColors.info;
        label = 'Running';
        break;
      case ExecutionStatus.success:
        color = AppColors.success;
        label = 'Success';
        break;
      case ExecutionStatus.failed:
        color = AppColors.error;
        label = 'Failed';
        break;
      case ExecutionStatus.cancelled:
        color = AppColors.textDisabled;
        label = 'Cancelled';
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
