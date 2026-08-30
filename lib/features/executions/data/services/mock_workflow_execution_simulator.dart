import 'dart:math';
import '../../domain/models/models.dart';
import '../../domain/repositories/execution_repository.dart';
import '../../domain/services/workflow_execution_simulator.dart';
import '../../../workflow_builder/domain/models/models.dart';

class MockWorkflowExecutionSimulator implements WorkflowExecutionSimulator {
  final ExecutionRepository _repository;
  final _random = Random();

  MockWorkflowExecutionSimulator(this._repository);

  @override
  Future<void> simulate(
    String automationId,
    Workflow workflow, {
    ExecutionFailureConfig failureConfig = ExecutionFailureConfig.none,
  }) async {
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

    await Future.delayed(const Duration(milliseconds: 500));

    // 2. Change execution to running
    execution = execution.copyWith(status: ExecutionStatus.running);
    await _repository.updateExecution(execution);

    bool hasFailed = false;
    String? failureMessage;

    // Determine if we should fail randomly and at which node index
    int? randomFailureIndex;
    if (failureConfig.failRandomly && workflow.nodes.isNotEmpty) {
      randomFailureIndex = _random.nextInt(workflow.nodes.length);
    }

    // 3. Execute workflow nodes sequentially
    for (int i = 0; i < workflow.nodes.length; i++) {
      final node = workflow.nodes[i];
      final stepStartTime = DateTime.now();
      final stepId = 'step_${stepStartTime.millisecondsSinceEpoch}_${node.id}';

      var step = ExecutionStep(
        id: stepId,
        nodeId: node.id,
        nodeTitle: node.title,
        status: ExecutionStepStatus.running,
        startedAt: stepStartTime,
      );
      await _repository.createExecutionStep(executionId, step);

      await Future.delayed(const Duration(seconds: 1));

      // Check for failure condition
      final shouldFail = (failureConfig.failAtNodeId == node.id) || (randomFailureIndex == i);

      if (shouldFail) {
        hasFailed = true;
        failureMessage = failureConfig.customErrorMessage ?? 'Simulated failure at node: ${node.title}';
        
        // 4. Mark step failed
        step = step.copyWith(
          status: ExecutionStepStatus.failed,
          completedAt: DateTime.now(),
          errorMessage: failureMessage,
        );
        await _repository.updateExecutionStep(executionId, step);
        
        // Stop subsequent steps
        break;
      }

      // 5. Mark node success
      step = step.copyWith(
        status: ExecutionStepStatus.success,
        completedAt: DateTime.now(),
        output: {'status': 'completed successfully'},
      );
      await _repository.updateExecutionStep(executionId, step);
    }

    // 6. Mark execution result
    final endTime = DateTime.now();
    if (hasFailed) {
      execution = execution.copyWith(
        status: ExecutionStatus.failed,
        completedAt: endTime,
        duration: endTime.difference(startTime),
        errorMessage: failureMessage,
      );
    } else {
      execution = execution.copyWith(
        status: ExecutionStatus.success,
        completedAt: endTime,
        duration: endTime.difference(startTime),
      );
    }
    await _repository.updateExecution(execution);
  }
}
