import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../workflow_builder/domain/models/models.dart';
import '../../../workflow_builder/presentation/widgets/widgets.dart';
import '../../domain/models/models.dart';
import '../providers/automation_providers.dart';

class AutomationDetailsPage extends ConsumerWidget {
  final String id;
  const AutomationDetailsPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final automationAsync = ref.watch(automationDetailsProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Automation Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // Future: Implement edit
            },
          ),
          const SizedBox(width: AppLayout.spaceS),
        ],
      ),
      body: automationAsync.when(
        data: (automation) {
          if (automation == null) {
            return const Center(child: Text('Automation not found'));
          }

          return PageContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, automation),
                const SizedBox(height: AppLayout.spaceXL),
                _buildWorkflowSection(context, ref, automation.workflowId),
                const SizedBox(height: AppLayout.spaceXL),
                _buildRecentExecutionsSection(context),
                const SizedBox(height: AppLayout.spaceXL),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Automation automation) {
    final theme = Theme.of(context);

    return Column(
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
                    automation.name,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppLayout.spaceXS),
                  Text(
                    automation.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppLayout.spaceM),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusBadge(status: automation.status),
                const SizedBox(height: AppLayout.spaceM),
                _RunNowButton(automationId: automation.id),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppLayout.spaceL),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _InfoItem(
                  label: 'Created',
                  value: 'Aug 30, 2026', // Mock date formatting
                  icon: Icons.calendar_today_outlined,
                ),
                const SizedBox(width: AppLayout.spaceXL),
                _InfoItem(
                  label: 'Last Run',
                  value: automation.lastExecutedAt != null ? '2 hours ago' : 'Never',
                  icon: Icons.history,
                ),
              ],
            ),
            _buildStatusToggle(context, automation),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusToggle(BuildContext context, Automation automation) {
    return Consumer(
      builder: (context, ref, child) {
        final actionsState = ref.watch(automationActionsProvider);
        final bool isToggling = actionsState.isLoading;
        
        final bool isActive = automation.status == AutomationStatus.active;

        return Row(
          children: [
            Text(
              isActive ? 'Active' : 'Paused',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isActive ? AppColors.success : AppColors.textDisabled,
              ),
            ),
            const SizedBox(width: AppLayout.spaceS),
            Switch(
              value: isActive,
              onChanged: isToggling
                  ? null
                  : (value) async {
                      await ref.read(automationActionsProvider.notifier).toggleStatus(automation.id);
                    },
            ),
          ],
        );
      },
    );
  }

  Widget _buildWorkflowSection(BuildContext context, WidgetRef ref, String? workflowId) {
    if (workflowId == null) return const SizedBox.shrink();

    final workflowAsync = ref.watch(workflowProvider(workflowId));
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Workflow',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppLayout.spaceM),
        workflowAsync.when(
          data: (workflow) {
            if (workflow == null) return const Text('Workflow details not found');
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: workflow.nodes.length,
              separatorBuilder: (context, index) {
                final sourceId = workflow.nodes[index].id;
                final targetId = workflow.nodes[index + 1].id;
                final edge = workflow.edges.firstWhere(
                  (e) => e.sourceNodeId == sourceId && e.targetNodeId == targetId,
                  orElse: () => WorkflowEdge(id: '', sourceNodeId: sourceId, targetNodeId: targetId),
                );
                return ConnectorLine(label: edge.label);
              },
              itemBuilder: (context, index) {
                return WorkflowStepCard(
                  stepNumber: index + 1,
                  node: workflow.nodes[index],
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error loading workflow: $err'),
        ),
      ],
    );
  }

  Widget _buildRecentExecutionsSection(BuildContext context) {
    final theme = Theme.of(context);
    // Future: Use specific provider for this automation's executions
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Executions',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(onPressed: () {}, child: const Text('View All')),
          ],
        ),
        const SizedBox(height: AppLayout.spaceS),
        const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppLayout.spaceL),
            child: Text('No executions yet.'),
          ),
        ),
      ],
    );
  }
}

class _RunNowButton extends ConsumerWidget {
  final String automationId;
  const _RunNowButton({required this.automationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionsState = ref.watch(automationActionsProvider);
    final bool isLoading = actionsState.isLoading;

    return ElevatedButton.icon(
      onPressed: isLoading
          ? null
          : () async {
              await ref.read(automationActionsProvider.notifier).runNow(automationId);
              
              final state = ref.read(automationActionsProvider);
              if (state.hasValue && state.value != null) {
                if (context.mounted) {
                  context.push(AppRoutes.executionDetails.replaceFirst(':id', state.value!));
                }
              } else if (state.hasError) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${state.error}')),
                  );
                }
              }
            },
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.play_arrow),
      label: const Text('Run Now'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(120, 40),
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
        horizontal: AppLayout.spaceM,
        vertical: AppLayout.spaceXS,
      ),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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

    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: AppLayout.spaceS),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
