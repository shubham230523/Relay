import '../../domain/models/models.dart';
import '../../domain/services/workflow_planner.dart';

class EmptyWorkflowPlanner implements WorkflowPlanner {
  @override
  Future<Workflow> generateWorkflow(String userPrompt) async {
    return Workflow(
      id: 'wf_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Generated Workflow',
      description: 'Result for: $userPrompt',
      nodes: [],
      edges: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
