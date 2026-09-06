import '../../domain/models/models.dart';
import '../../domain/repositories/workflow_repository.dart';

class EmptyWorkflowRepository implements WorkflowRepository {
  @override
  Future<Workflow?> getWorkflowById(String id) async {
    return null;
  }

  @override
  Future<Workflow> saveWorkflow(Workflow workflow) async {
    return workflow;
  }
}
