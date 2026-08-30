import '../../../workflow_builder/domain/models/models.dart';

class ExecutionFailureConfig {
  final String? failAtNodeId;
  final bool failRandomly;
  final String? customErrorMessage;

  const ExecutionFailureConfig({
    this.failAtNodeId,
    this.failRandomly = false,
    this.customErrorMessage,
  });

  static const none = ExecutionFailureConfig();
}

abstract class WorkflowExecutionSimulator {
  Future<String> simulate(
    String automationId,
    Workflow workflow, {
    ExecutionFailureConfig failureConfig = ExecutionFailureConfig.none,
  });
}
