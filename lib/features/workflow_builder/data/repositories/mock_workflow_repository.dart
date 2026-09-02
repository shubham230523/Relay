import '../../domain/models/models.dart';
import '../../domain/repositories/workflow_repository.dart';
import 'package:relay/features/templates/domain/models/mock_templates.dart';

class MockWorkflowRepository implements WorkflowRepository {
  final Map<String, Workflow> _workflows = {
    for (var t in MockTemplates.all) t.workflow.id: t.workflow,
  };

  @override
  Future<Workflow> saveWorkflow(Workflow workflow) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _workflows[workflow.id] = workflow;
    return workflow;
  }

  @override
  Future<Workflow?> getWorkflowById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _workflows[id];
  }
}
