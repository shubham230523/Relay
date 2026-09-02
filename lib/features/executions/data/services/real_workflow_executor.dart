import 'package:relay/core/services/services.dart';
import 'package:relay/features/workflow_builder/domain/models/models.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/execution_repository.dart';
import '../../domain/services/workflow_executor.dart';

class RealWorkflowExecutor implements WorkflowExecutor {
  final ExecutionRepository _repository;
  final NotificationService _notificationService;
  final GmailService _gmailService;
  final SheetsService _sheetsService;
  final SlackService _slackService;
  final AiService _aiService;

  RealWorkflowExecutor(
    this._repository,
    this._notificationService,
    this._gmailService,
    this._sheetsService,
    this._slackService,
    this._aiService,
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
        input: executionContext.isNotEmpty ? Map.from(executionContext) : null,
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
    final title = node.title.toLowerCase();

    switch (node.type) {
      case WorkflowNodeType.trigger:
        if (title.contains('email')) {
          final messages = await _gmailService.listMessages(
            query: node.configuration['filter'] ?? '',
          );
          if (messages.isEmpty) throw Exception('No new emails found matching criteria');
          return {'messageIds': messages.map((m) => m.id).toList(), 'count': messages.length};
        } else if (title.contains('schedule') || title.contains('time')) {
          return {'status': 'Triggered manually', 'scheduled_time': '8:00 AM'};
        }
        break;

      case WorkflowNodeType.action:
        if (title.contains('fetch') && title.contains('email')) {
          final messages = await _gmailService.listMessages(
            query: 'newer_than:1d', // Last 24 hours as per template
          );
          if (messages.isEmpty) {
            return {'status': 'success', 'count': 0, 'data': 'No emails found in the last 24 hours.'};
          }
          
          final ids = messages.map((m) => m.id!).toList();
          final fullMessages = await _gmailService.getFullMessages(ids);
          final snippets = fullMessages.map((m) => 'From: ${m.snippet}').join('\n---\n');
          
          return {
            'count': fullMessages.length,
            'data': snippets,
            'subjects': fullMessages.map((m) => m.snippet).toList(),
          };
        } else if (title.contains('notification')) {
          // Find input from previous AI step if available
          String message = 'Automation ${node.title} completed.';
          
          // Try to find a summary in context
          for (final val in context.values) {
            if (val is Map && val.containsKey('summary')) {
              message = val['summary'];
              break;
            }
          }

          await _notificationService.showNotification(
            id: node.id.hashCode,
            title: 'Relay Summary',
            body: message,
          );
          return {'status': 'sent', 'message': message};
        } else if (title.contains('sheets')) {
          final spreadsheetId = node.configuration['spreadsheetId'] ?? 'default_sheet';
          await _sheetsService.appendRow(spreadsheetId, 'A1', ['Execution', DateTime.now().toString()]);
          return {'status': 'row added'};
        } else if (title.contains('slack')) {
          final webhookUrl = node.configuration['webhookUrl'] ?? '';
          if (webhookUrl.isNotEmpty) {
            await _slackService.sendMessage(webhookUrl, 'Relay Automation: ${node.description}');
            return {'status': 'message sent'};
          }
        }
        break;

      case WorkflowNodeType.ai:
        // Use Gemini to summarize data from context
        String inputData = '';
        for (final val in context.values) {
          if (val is Map && val.containsKey('data')) {
            inputData += val['data'];
          }
        }

        if (inputData.isEmpty) {
          inputData = node.description;
        }

        final summary = await _aiService.summarize(inputData);
        return {'summary': summary};

      case WorkflowNodeType.logic:
        return {'condition_met': true};
    }

    await Future.delayed(const Duration(milliseconds: 500));
    return {'status': 'executed', 'node': node.title};
  }
}
