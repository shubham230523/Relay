import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/execution_providers.dart';
import '../../domain/models/models.dart';

class ExecutionDetailsPage extends ConsumerWidget {
  final String id;
  const ExecutionDetailsPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final executionAsync = ref.watch(executionDetailsProvider(id));
    final stepsAsync = ref.watch(executionStepsProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Execution Details'),
      ),
      body: executionAsync.when(
        data: (execution) {
          if (execution == null) {
            return const Center(child: Text('Execution not found'));
          }

          return PageContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, execution),
                const SizedBox(height: AppLayout.spaceXL),
                Text(
                  'Steps',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppLayout.spaceM),
                stepsAsync.when(
                  data: (steps) => _buildStepsList(context, steps),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, st) => Text('Error loading steps: $err'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Execution execution) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppLayout.spaceM),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: theme.textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
                    ),
                    _StatusLabel(status: execution.status),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Started At',
                      style: theme.textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
                    ),
                    Text(
                      'Just now', // Mock formatting
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            if (execution.errorMessage != null) ...[
              const SizedBox(height: AppLayout.spaceM),
              Container(
                padding: const EdgeInsets.all(AppLayout.spaceM),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppLayout.buttonRadius),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 16),
                    const SizedBox(width: AppLayout.spaceS),
                    Expanded(
                      child: Text(
                        execution.errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStepsList(BuildContext context, List<ExecutionStep> steps) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppLayout.spaceS),
      itemBuilder: (context, index) {
        final step = steps[index];
        return _StepTile(step: step);
      },
    );
  }
}

class _StatusLabel extends StatelessWidget {
  final ExecutionStatus status;
  const _StatusLabel({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color color;
    String label;

    switch (status) {
      case ExecutionStatus.pending:
        color = AppColors.warning;
        label = 'Pending';
      case ExecutionStatus.running:
        color = AppColors.info;
        label = 'Running';
      case ExecutionStatus.success:
        color = AppColors.success;
        label = 'Success';
      case ExecutionStatus.failed:
        color = AppColors.error;
        label = 'Failed';
      case ExecutionStatus.cancelled:
        color = AppColors.textDisabled;
        label = 'Cancelled';
    }

    return Text(
      label,
      style: theme.textTheme.titleMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final ExecutionStep step;
  const _StepTile({required this.step});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    IconData icon;
    Color color;
    
    switch (step.status) {
      case ExecutionStepStatus.pending:
        icon = Icons.schedule;
        color = AppColors.textDisabled;
      case ExecutionStepStatus.running:
        icon = Icons.sync;
        color = AppColors.info;
      case ExecutionStepStatus.success:
        icon = Icons.check_circle;
        color = AppColors.success;
      case ExecutionStepStatus.failed:
        icon = Icons.error;
        color = AppColors.error;
      case ExecutionStepStatus.skipped:
        icon = Icons.skip_next;
        color = AppColors.textDisabled;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppLayout.cardRadius),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          step.nodeTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: step.errorMessage != null
            ? Text(step.errorMessage!, style: const TextStyle(color: AppColors.error))
            : Text(step.status.name.toUpperCase()),
        trailing: step.status == ExecutionStepStatus.running
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : null,
      ),
    );
  }
}
