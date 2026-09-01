import '../../../workflow_builder/domain/models/models.dart';

abstract class WorkflowExecutor {
  Future<String> execute(String automationId, Workflow workflow);
}
