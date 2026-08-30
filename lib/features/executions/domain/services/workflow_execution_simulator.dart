import '../../../workflow_builder/domain/models/models.dart';

abstract class WorkflowExecutionSimulator {
  Future<void> simulate(String automationId, Workflow workflow);
}
