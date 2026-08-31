import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../widgets/widgets.dart';
import '../providers/execution_providers.dart';
import '../../../workflow_builder/domain/models/models.dart';
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
                if (execution.status == ExecutionStatus.failed) ...[
                  const SizedBox(height: AppLayout.spaceL),
                  stepsAsync.when(
                    data: (steps) {
                      final failedStep = steps.firstWhere(
                        (s) => s.status == ExecutionStepStatus.failed,
                        orElse: () => ExecutionStep(
                          id: '',
                          nodeId: '',
                          nodeTitle: 'Unknown Step',
                          nodeType: WorkflowNodeType.action,
                          status: ExecutionStepStatus.failed,
                          startedAt: DateTime.now(),
                        ),
                      );
                      return ExecutionFailureCard(
                        failedStepName: failedStep.nodeTitle,
                        errorMessage: execution.errorMessage ?? 'An unexpected error occurred.',
                        errorCategory: _getErrorCategory(execution.errorMessage),
                        failureTime: execution.completedAt ?? DateTime.now(),
                        onRetry: () {
                          ref.read(executionActionsProvider.notifier).retryExecution(
                                execution.id,
                                execution.workflowId,
                              );
                        },
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (e, s) => const SizedBox.shrink(),
                  ),
                ],
                const SizedBox(height: AppLayout.spaceXL),
                Text(
                  'Execution steps',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppLayout.spaceL),
                stepsAsync.when(
                  data: (steps) => ExecutionTimeline(steps: steps),
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
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm:ss');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppLayout.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Automation',
                        style: theme.textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
                      ),
                      Text(
                        execution.automationName,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                ExecutionStatusBadge(status: execution.status),
              ],
            ),
            const SizedBox(height: AppLayout.spaceL),
            const Divider(),
            const SizedBox(height: AppLayout.spaceL),
            Row(
              children: [
                _InfoItem(
                  label: 'Start time',
                  value: dateFormat.format(execution.startedAt),
                  icon: Icons.play_arrow_outlined,
                ),
                const Spacer(),
                _InfoItem(
                  label: 'Completion Time',
                  value: execution.completedAt != null ? dateFormat.format(execution.completedAt!) : '-',
                  icon: Icons.stop_outlined,
                ),
                const Spacer(),
                _InfoItem(
                  label: 'Duration',
                  value: execution.duration != null ? '${execution.duration!.inSeconds}s' : '-',
                  icon: Icons.timer_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getErrorCategory(String? message) {
    if (message == null) return 'Unknown';
    final lower = message.toLowerCase();
    if (lower.contains('timeout')) return 'Timeout';
    if (lower.contains('network') || lower.contains('connect')) return 'Network';
    if (lower.contains('auth') || lower.contains('permission')) return 'Authentication';
    if (lower.contains('config')) return 'Configuration';
    return 'Execution Error';
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
