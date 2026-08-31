import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../workflow_builder/domain/models/models.dart';
import '../../../workflow_builder/presentation/providers/workflow_builder_providers.dart';
import '../../../workflow_builder/presentation/widgets/widgets.dart';
import '../../domain/models/automation_template.dart';
import '../../domain/models/mock_templates.dart';

class TemplateDetailsPage extends ConsumerWidget {
  final String id;
  const TemplateDetailsPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real app, we'd use a provider with the ID. For mock, find it in the list.
    final template = MockTemplates.all.firstWhere((t) => t.id == id);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Template Details'),
      ),
      body: PageContainer(
        maxWidth: 800,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppLayout.spaceS),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppLayout.buttonRadius),
                  ),
                  child: Icon(template.icon, color: theme.colorScheme.primary, size: 32),
                ),
                const SizedBox(width: AppLayout.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        template.category.name.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppLayout.spaceL),
            Text(
              'Description',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppLayout.spaceS),
            Text(
              template.description,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: AppLayout.spaceXL),
            Text(
              'Workflow Preview',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppLayout.spaceM),
            _buildWorkflowPreview(context, template),
            const SizedBox(height: AppLayout.spaceXL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Flow: Use Template -> Set as current workflow in builder -> Navigate to Preview
                  ref.read(workflowGenerationProvider.notifier).reset();
                  
                  // Manually inject the template workflow into the generation state
                  // This reuses the existing approval logic in WorkflowPreviewPage
                  ref.read(workflowGenerationProvider.notifier).generateFromTemplate(
                    template.workflow,
                    'Based on template: ${template.name}',
                  );
                  
                  context.push(AppRoutes.workflowDetails);
                },
                child: const Text('Use Template'),
              ),
            ),
            const SizedBox(height: AppLayout.spaceXL),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkflowPreview(BuildContext context, AutomationTemplate template) {
    final workflow = template.workflow;
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
  }
}
