import '../../domain/models/models.dart';
import '../../domain/repositories/execution_repository.dart';
import '../../domain/services/workflow_execution_simulator.dart';
import '../../../workflow_builder/domain/models/models.dart';

class MockWorkflowExecutionSimulator implements WorkflowExecutionSimulator {
  final ExecutionRepository _repository;

  MockWorkflowExecutionSimulator(this._repository);

  @override
  Future<void> simulate(String automationId, Workflow workflow) async {
    final startTime = DateTime.now();
    final executionId = 'exec_${startTime.millisecondsSinceEpoch}';

    // 1. Create execution with pending status
    var execution = Execution(
      id: executionId,
      automationId: automationId,
      workflowId: workflow.id,
      status: ExecutionStatus.pending,
      startedAt: startTime,
    );
    await _repository.createExecution(execution);

    // Small delay before starting
    await Future.delayed(const Duration(milliseconds: 500));

    // 2. Change execution to running
    execution = execution.copyWith(status: ExecutionStatus.running);
    await _repository.updateExecution(execution);

    // 3. Execute workflow nodes sequentially
    for (final node in workflow.nodes) {
      final stepStartTime = DateTime.now();
      final stepId = 'step_${stepStartTime.millisecondsSinceEpoch}_${node.id}';

      // Create step with running status
      var step = ExecutionStep(
        id: stepId,
        nodeId: node.id,
        nodeTitle: node.title,
        status: ExecutionStepStatus.running,
        startedAt: stepStartTime,
      );
      await _repository.createExecutionStep(executionId, step);

      // 4. Add artificial delay
      await Future.delayed(const Duration(seconds: 1));

      // 5. Mark node success
      step = step.copyWith(
        status: ExecutionStepStatus.success,
        completedAt: DateTime.now(),
        output: {'status': 'completed successfully'},
      );
      await _repository.updateExecutionStep(executionId, step);
    }

    // 6. Mark workflow success
    final endTime = DateTime.now();
    execution = execution.copyWith(
      status: ExecutionStatus.success,
      completedAt: endTime,
      duration: endTime.difference(startTime),
    );
    await _repository.updateExecution(execution);
  }
}
