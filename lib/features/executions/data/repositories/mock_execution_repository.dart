import '../../../workflow_builder/domain/models/models.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/execution_repository.dart';

class MockExecutionRepository implements ExecutionRepository {
  final List<Execution> _executions = [];
  final Map<String, List<ExecutionStep>> _executionSteps = {};

  MockExecutionRepository() {
    _initMockData();
  }

  void _initMockData() {
    final now = DateTime.now();
    final e1 = Execution(
      id: 'exec_1',
      automationId: 'auto_1',
      automationName: 'GitHub to Slack Sync',
      workflowId: 'wf_1',
      status: ExecutionStatus.success,
      startedAt: now.subtract(const Duration(hours: 1)),
      completedAt: now.subtract(const Duration(minutes: 59)),
      duration: const Duration(minutes: 1),
    );

    final e2 = Execution(
      id: 'exec_2',
      automationId: 'auto_1',
      automationName: 'GitHub to Slack Sync',
      workflowId: 'wf_1',
      status: ExecutionStatus.failed,
      startedAt: now.subtract(const Duration(hours: 2)),
      completedAt: now.subtract(const Duration(minutes: 118)),
      duration: const Duration(minutes: 2),
      errorMessage: 'Failed to connect to Google Sheets',
    );

    _executions.addAll([e1, e2]);

    _executionSteps[e1.id] = [
      ExecutionStep(
        id: 'step_1_1',
        nodeId: 'node_1',
        nodeTitle: 'New Email',
        nodeType: WorkflowNodeType.trigger,
        status: ExecutionStepStatus.success,
        startedAt: e1.startedAt,
        completedAt: e1.startedAt.add(const Duration(seconds: 5)),
        output: {'subject': 'Invoice #123'},
      ),
      ExecutionStep(
        id: 'step_1_2',
        nodeId: 'node_2',
        nodeTitle: 'Analyze Invoice',
        nodeType: WorkflowNodeType.ai,
        status: ExecutionStepStatus.success,
        startedAt: e1.startedAt.add(const Duration(seconds: 5)),
        completedAt: e1.startedAt.add(const Duration(seconds: 45)),
        input: {'subject': 'Invoice #123'},
        output: {'amount': 45000, 'vendor': 'Acme Corp'},
      ),
    ];

    _executionSteps[e2.id] = [
      ExecutionStep(
        id: 'step_2_1',
        nodeId: 'node_1',
        nodeTitle: 'New Email',
        nodeType: WorkflowNodeType.trigger,
        status: ExecutionStepStatus.success,
        startedAt: e2.startedAt,
        completedAt: e2.startedAt.add(const Duration(seconds: 5)),
      ),
      ExecutionStep(
        id: 'step_2_2',
        nodeId: 'node_2',
        nodeTitle: 'Analyze Invoice',
        nodeType: WorkflowNodeType.ai,
        status: ExecutionStepStatus.failed,
        startedAt: e2.startedAt.add(const Duration(seconds: 5)),
        completedAt: e2.startedAt.add(const Duration(seconds: 10)),
        errorMessage: 'Connection timed out',
      ),
    ];
  }

  @override
  Future<List<Execution>> getExecutionHistory({String? automationId}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (automationId != null) {
      return _executions.where((e) => e.automationId == automationId).toList();
    }
    return List.unmodifiable(_executions);
  }

  @override
  Future<Execution?> getExecutionById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _executions.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ExecutionStep>> getExecutionSteps(String executionId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_executionSteps[executionId] ?? []);
  }

  @override
  Future<Execution> createExecution(Execution execution) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _executions.add(execution);
    return execution;
  }

  @override
  Future<Execution> updateExecution(Execution execution) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _executions.indexWhere((e) => e.id == execution.id);
    if (index != -1) {
      _executions[index] = execution;
      return execution;
    }
    throw Exception('Execution not found');
  }

  @override
  Future<ExecutionStep> createExecutionStep(String executionId, ExecutionStep step) async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (!_executionSteps.containsKey(executionId)) {
      _executionSteps[executionId] = [];
    }
    _executionSteps[executionId]!.add(step);
    return step;
  }

  @override
  Future<ExecutionStep> updateExecutionStep(String executionId, ExecutionStep step) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final steps = _executionSteps[executionId];
    if (steps != null) {
      final index = steps.indexWhere((s) => s.id == step.id);
      if (index != -1) {
        steps[index] = step;
        return step;
      }
    }
    throw Exception('Step not found');
  }
}
