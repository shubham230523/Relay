import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/workflow_builder_providers.dart';

class WorkflowDetailsPage extends ConsumerWidget {
  const WorkflowDetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workflow = ref.watch(workflowGenerationProvider).workflow;

    return Scaffold(
      appBar: AppBar(
        title: Text(workflow?.name ?? 'Workflow Details'),
      ),
      body: PageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (workflow == null)
              const Center(child: Text('No workflow data available'))
            else ...[
              Text(
                workflow.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(workflow.description),
              const SizedBox(height: 24),
              Text(
                'Nodes (${workflow.nodes.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ...workflow.nodes.map((node) => ListTile(
                    leading: CircleAvatar(child: Text(node.type.name[0].toUpperCase())),
                    title: Text(node.title),
                    subtitle: Text(node.description),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
