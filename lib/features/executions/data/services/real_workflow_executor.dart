import '../../../../core/services/services.dart';
import '../../../workflow_builder/domain/models/models.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/execution_repository.dart';
import '../../domain/services/workflow_executor.dart';

class RealWorkflowExecutor implements WorkflowExecutor {
  final ExecutionRepository _repository;
  final NotificationService _notificationService;
  final GmailService _gmailService;
  final SheetsService _sheetsService;
  final SlackService _slackService;

  RealWorkflowExecutor(
    this._repository,
    this._notificationService,
    this._gmailService,
    this._sheetsService,
    this._slackService,
  );

  @override
  Future<String> execute(String automationId, Workflow workflow) async {
    final startTime = DateTime.now();
    final executionId = 'exec_${startTime.millisecondsSinceEpoch}';

    // 1. Create execution
    var execution = Execution(
      id: executionId,
      automationId: automationId,
      automationName: workflow.name,
      workflowId: workflow.id,
      status: ExecutionStatus.pending,
      startedAt: startTime,
    );
    await _repository.createExecution(execution);

    // Run in background
    _run(execution, workflow);

    return executionId;
  }

  Future<void> _run(Execution initialExecution, Workflow workflow) async {
    var execution = initialExecution;
    final executionId = execution.id;
    final startTime = execution.startedAt;
    
    // Execution context to pass data between steps
    final Map<String, dynamic> executionContext = {};

    await _repository.updateExecution(execution.copyWith(status: ExecutionStatus.running));

    bool hasFailed = false;
    String? failureMessage;

    for (final node in workflow.nodes) {
      final stepStartTime = DateTime.now();
      final stepId = 'step_${stepStartTime.millisecondsSinceEpoch}_${node.id}';

      var step = ExecutionStep(
        id: stepId,
        nodeId: node.id,
        nodeTitle: node.title,
        nodeType: node.type,
        status: ExecutionStepStatus.running,
        startedAt: stepStartTime,
      );
      await _repository.createExecutionStep(executionId, step);

      try {
        final result = await _executeNode(node, executionContext);
        
        // Update context with node output
        if (result != null) {
          executionContext[node.id] = result;
        }

        step = step.copyWith(
          status: ExecutionStepStatus.success,
          completedAt: DateTime.now(),
          output: result,
        );
        await _repository.updateExecutionStep(executionId, step);
      } catch (e) {
        hasFailed = true;
        failureMessage = e.toString();
        
        step = step.copyWith(
          status: ExecutionStepStatus.failed,
          completedAt: DateTime.now(),
          errorMessage: failureMessage,
        );
        await _repository.updateExecutionStep(executionId, step);
        break;
      }
    }

    final endTime = DateTime.now();
    execution = execution.copyWith(
      status: hasFailed ? ExecutionStatus.failed : ExecutionStatus.success,
      completedAt: endTime,
      duration: endTime.difference(startTime),
      errorMessage: failureMessage,
    );
    await _repository.updateExecution(execution);
    
    if (!hasFailed) {
      await _notificationService.showNotification(
        id: workflow.id.hashCode,
        title: 'Automation Successful',
        body: '${workflow.name} completed successfully.',
      );
    }
  }

  Future<Map<String, dynamic>?> _executeNode(
    WorkflowNode node,
    Map<String, dynamic> context,
  ) async {
    switch (node.type) {
      case WorkflowNodeType.trigger:
        if (node.title.toLowerCase().contains('email')) {
          final messages = await _gmailService.listMessages(
            query: node.configuration['filter'] ?? '',
          );
          if (messages.isEmpty) throw Exception('No new emails found matching criteria');
          return {'messageId': messages.first.id, 'count': messages.length};
        }
        break;

      case WorkflowNodeType.action:
        if (node.title.toLowerCase().contains('sheets')) {
          final spreadsheetId = node.configuration['spreadsheetId'] ?? 'default_sheet';
          // In a real app, we'd extract values from context
          await _sheetsService.appendRow(spreadsheetId, 'A1', ['Execution', DateTime.now().toString()]);
          return {'status': 'row added'};
        } else if (node.title.toLowerCase().contains('slack')) {
          final webhookUrl = node.configuration['webhookUrl'] ?? '';
          if (webhookUrl.isNotEmpty) {
            await _slackService.sendMessage(webhookUrl, 'Relay Automation: ${node.description}');
            return {'status': 'message sent'};
          }
        }
        break;

      case WorkflowNodeType.ai:
        // Placeholder for Gemini implementation
        await Future.delayed(const Duration(seconds: 2));
        return {'summary': 'Simulated AI summary of input data'};

      case WorkflowNodeType.logic:
        // Simple true/false logic
        return {'condition_met': true};
    }

    await Future.delayed(const Duration(seconds: 1));
    return {'status': 'executed', 'node': node.title};
  }
}
