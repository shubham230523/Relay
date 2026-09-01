import 'dart:math';
import '../../../../core/services/services.dart';
import '../../../workflow_builder/domain/models/models.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/execution_repository.dart';
import '../../domain/services/workflow_execution_simulator.dart';

class MockWorkflowExecutionSimulator implements WorkflowExecutionSimulator {
  final ExecutionRepository _repository;
  final NotificationService _notificationService;
  final _random = Random();

  MockWorkflowExecutionSimulator(this._repository, this._notificationService);

  @override
  Future<String> simulate(
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
      automationName: workflow.name,
      workflowId: workflow.id,
      status: ExecutionStatus.pending,
      startedAt: startTime,
    );
    await _repository.createExecution(execution);

    _runSimulation(execution, workflow, failureConfig);

    return executionId;
  }

  @override
  Future<void> retry(String executionId, Workflow workflow) async {
    final execution = await _repository.getExecutionById(executionId);
    if (execution == null) throw Exception('Execution not found');

    final steps = await _repository.getExecutionSteps(executionId);
    final failedStepIndex = steps.indexWhere((s) => s.status == ExecutionStepStatus.failed);
    
    if (failedStepIndex == -1) return;

    // Reset execution status
    await _repository.updateExecution(execution.copyWith(
      status: ExecutionStatus.running,
      errorMessage: null,
    ));

    // Resume from the failed node
    _runSimulation(
      execution,
      workflow,
      ExecutionFailureConfig.none,
      startIndex: failedStepIndex,
    );
  }

  Future<void> _runSimulation(
    Execution initialExecution,
    Workflow workflow,
    ExecutionFailureConfig failureConfig, {
    int startIndex = 0,
  }) async {
    var execution = initialExecution;
    final executionId = execution.id;
    final startTime = execution.startedAt;

    if (startIndex == 0) {
      await Future.delayed(const Duration(milliseconds: 500));

      // 2. Change execution to running
      execution = execution.copyWith(status: ExecutionStatus.running);
      await _repository.updateExecution(execution);
    }

    bool hasFailed = false;
    String? failureMessage;

    int? randomFailureIndex;
    if (failureConfig.failRandomly && workflow.nodes.isNotEmpty) {
      randomFailureIndex = _random.nextInt(workflow.nodes.length);
    }

    // 3. Execute workflow nodes sequentially
    for (int i = startIndex; i < workflow.nodes.length; i++) {
      final node = workflow.nodes[i];
      final stepStartTime = DateTime.now();
      
      final existingSteps = await _repository.getExecutionSteps(executionId);
      final existingStep = existingSteps.firstWhere((s) => s.nodeId == node.id, orElse: () => ExecutionStep(
        id: 'step_${stepStartTime.millisecondsSinceEpoch}_${node.id}',
        nodeId: node.id,
        nodeTitle: node.title,
        nodeType: node.type,
        status: ExecutionStepStatus.pending,
        startedAt: stepStartTime,
      ));

      var step = existingStep.copyWith(
        status: ExecutionStepStatus.running,
        startedAt: stepStartTime,
        errorMessage: null,
      );
      
      if (existingSteps.any((s) => s.id == step.id)) {
        await _repository.updateExecutionStep(executionId, step);
      } else {
        await _repository.createExecutionStep(executionId, step);
      }

      await Future.delayed(const Duration(seconds: 1));

      // Notification logic: trigger real local notification for Notify or Send steps
      if (node.type == WorkflowNodeType.action && 
          (node.title.toLowerCase().contains('notify') || node.title.toLowerCase().contains('send'))) {
        await _notificationService.showNotification(
          id: node.id.hashCode,
          title: 'Relay Automation',
          body: 'Workflow step completed: ${node.title}',
        );
      }

      final shouldFail = (failureConfig.failAtNodeId == node.id) || (randomFailureIndex == i);

      if (shouldFail) {
        hasFailed = true;
        failureMessage = failureConfig.customErrorMessage ?? 'Simulated failure at node: ${node.title}';
        
        step = step.copyWith(
          status: ExecutionStepStatus.failed,
          completedAt: DateTime.now(),
          errorMessage: failureMessage,
        );
        await _repository.updateExecutionStep(executionId, step);
        break;
      }

      step = step.copyWith(
        status: ExecutionStepStatus.success,
        completedAt: DateTime.now(),
        output: {'status': 'completed successfully'},
      );
      await _repository.updateExecutionStep(executionId, step);
    }

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
        errorMessage: null,
      );
    }
    await _repository.updateExecution(execution);
  }
}
