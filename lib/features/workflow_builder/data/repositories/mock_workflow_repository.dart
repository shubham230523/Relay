import '../../domain/models/models.dart';
import '../../domain/repositories/workflow_repository.dart';

class MockWorkflowRepository implements WorkflowRepository {
  final Map<String, Workflow> _workflows = {};

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
