import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/models/models.dart';
import '../providers/workflow_builder_providers.dart';
import '../widgets/widgets.dart';

class WorkflowPreviewPage extends ConsumerWidget {
  const WorkflowPreviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workflowGenerationProvider);
    final workflow = state.workflow;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workflow Preview'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: PageContainer(
        maxWidth: 800,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (workflow == null)
              const Center(child: Text('No workflow generated.'))
            else ...[
              // 1. Workflow Name
              Text(
                workflow.name,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppLayout.spaceL),

              // 2. Original User Request
              _SectionTitle(title: 'Your Request'),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppLayout.spaceM),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(AppLayout.cardRadius),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Text(
                  state.originalPrompt ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: AppLayout.spaceL),

              // 3. Workflow Summary
              _SectionTitle(title: 'Summary'),
              Text(
                workflow.description,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: AppLayout.spaceL),

              // 3.5 How this works
              _SectionTitle(title: 'How this works'),
              _HowItWorksSection(workflow: workflow),
              const SizedBox(height: AppLayout.spaceXL),

              // 4. Generated Workflow Steps
              _SectionTitle(title: 'Automation Steps'),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: workflow.nodes.length,
                separatorBuilder: (context, index) => _ConnectorLine(),
                itemBuilder: (context, index) {
                  final node = workflow.nodes[index];
                  return WorkflowStepCard(node: node, stepNumber: index + 1);
                },
              ),
              const SizedBox(height: AppLayout.spaceXL),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Edit Request'),
                    ),
                  ),
                  const SizedBox(width: AppLayout.spaceM),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showApprovalDialog(context, workflow),
                      child: const Text('Approve Workflow'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppLayout.spaceXL),
            ],
          ],
        ),
      ),
    );
  }

  void _showApprovalDialog(BuildContext context, Workflow workflow) {
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final state = ref.watch(workflowGenerationProvider);
          
          return AlertDialog(
            title: const Text('Approve Workflow'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Workflow: ${workflow.name}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppLayout.spaceS),
                Text('This automation contains ${workflow.nodes.length} steps.'),
                const SizedBox(height: AppLayout.spaceM),
                const Text(
                  'Once approved, this workflow will be activated. You can modify these steps later in the workflow builder.',
                ),
                if (state.isSaving) ...[
                  const SizedBox(height: AppLayout.spaceM),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: state.isSaving ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: state.isSaving
                    ? null
                    : () async {
                        final notifier = ref.read(workflowGenerationProvider.notifier);
                        await notifier.approveWorkflow();

                        final finalState = ref.read(workflowGenerationProvider);
                        if (finalState.savedAutomation != null) {
                          if (context.mounted) {
                            Navigator.of(context).pop(); // Close dialog
                            context.go(AppRoutes.automationDetails.replaceFirst(':id', finalState.savedAutomation!.id));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Workflow approved and activated!')),
                            );
                          }
                        } else if (finalState.error != null) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${finalState.error}')),
                            );
                          }
                        }
                      },
                child: const Text('Approve & Activate'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppLayout.spaceS),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _ConnectorLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 2,
        height: 24,
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }
}

class _HowItWorksSection extends StatelessWidget {
  final Workflow workflow;

  const _HowItWorksSection({required this.workflow});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final explanation = _generateExplanation(workflow);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppLayout.spaceM),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppLayout.cardRadius),
        // ignore: deprecated_member_use
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Text(
        explanation,
        style: theme.textTheme.bodyMedium?.copyWith(
          height: 1.5,
        ),
      ),
    );
  }

  String _generateExplanation(Workflow workflow) {
    // Check if it's the invoice workflow
    if (workflow.name.toLowerCase().contains('invoice')) {
      return 'When a new email arrives, Relay analyzes the invoice, extracts important details, stores them in Google Sheets and sends a notification when the amount exceeds \$50,000.';
    }

    // Generic generation logic for other workflows
    final buffer = StringBuffer();
    final trigger = workflow.nodes.where((n) => n.type == WorkflowNodeType.trigger).firstOrNull;
    final others = workflow.nodes.where((n) => n.type != WorkflowNodeType.trigger).toList();

    if (trigger != null) {
      buffer.write('When ${trigger.title.toLowerCase()} happens, ');
    }

    buffer.write('Relay will ');
    for (var i = 0; i < others.length; i++) {
      final node = others[i];
      buffer.write(node.title.toLowerCase());
      if (i < others.length - 2) {
        buffer.write(', ');
      } else if (i == others.length - 2) {
        buffer.write(' and ');
      }
    }
    buffer.write('.');

    return buffer.toString();
  }
}
