import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/mock_execution_repository.dart';
import '../../data/services/mock_recovery_agent.dart';
import '../../data/services/mock_workflow_execution_simulator.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/execution_repository.dart';
import '../../domain/services/services.dart';
import '../../../automations/presentation/providers/automation_providers.dart';

final executionRepositoryProvider = Provider<ExecutionRepository>((ref) {
  return MockExecutionRepository();
});

final workflowExecutionSimulatorProvider = Provider<WorkflowExecutionSimulator>((ref) {
  final repo = ref.watch(executionRepositoryProvider);
  return MockWorkflowExecutionSimulator(repo);
});

final recoveryAgentProvider = Provider<RecoveryAgent>((ref) {
  return MockRecoveryAgent();
});

class ExecutionActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final WorkflowExecutionSimulator _simulator;
  final Ref _ref;

  ExecutionActionsNotifier(this._simulator, this._ref) : super(const AsyncValue.data(null));

  Future<void> retryExecution(String executionId, String workflowId) async {
    state = const AsyncValue.loading();
    try {
      final workflow = await _ref.read(workflowProvider(workflowId).future);
      if (workflow == null) throw Exception('Workflow not found');

      await _simulator.retry(executionId, workflow);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> analyzeFailure(String executionId) async {
    _ref.read(failureAnalysisProvider(executionId).notifier).analyze();
  }
}

final executionActionsProvider = StateNotifierProvider<ExecutionActionsNotifier, AsyncValue<void>>((ref) {
  final simulator = ref.watch(workflowExecutionSimulatorProvider);
  return ExecutionActionsNotifier(simulator, ref);
});

class FailureAnalysisNotifier extends StateNotifier<AsyncValue<FailureAnalysis?>> {
  final String _executionId;
  final RecoveryAgent _agent;
  final Ref _ref;

  FailureAnalysisNotifier(this._executionId, this._agent, this._ref) : super(const AsyncValue.data(null));

  Future<void> analyze() async {
    state = const AsyncValue.loading();
    try {
      final execution = await _ref.read(executionDetailsProvider(_executionId).future);
      final steps = await _ref.read(executionStepsProvider(_executionId).future);

      if (execution == null) throw Exception('Execution not found');

      final analysis = await _agent.analyzeFailure(execution, steps);
      state = AsyncValue.data(analysis);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final failureAnalysisProvider =
    StateNotifierProvider.family<FailureAnalysisNotifier, AsyncValue<FailureAnalysis?>, String>((ref, executionId) {
  final agent = ref.watch(recoveryAgentProvider);
  return FailureAnalysisNotifier(executionId, agent, ref);
});

final executionHistoryProvider = FutureProvider.family<List<Execution>, String?>((ref, automationId) async {
  final repo = ref.watch(executionRepositoryProvider);
  return repo.getExecutionHistory(automationId: automationId);
});

final executionDetailsProvider = StreamProvider.family<Execution?, String>((ref, id) {
  final repo = ref.watch(executionRepositoryProvider);
  return repo.watchExecution(id);
});

final executionStepsProvider = StreamProvider.family<List<ExecutionStep>, String>((ref, executionId) {
  final repo = ref.watch(executionRepositoryProvider);
  return repo.watchExecutionSteps(executionId);
});

final executionStatusFilterProvider = StateProvider<ExecutionStatus?>((ref) => null);

final filteredExecutionHistoryProvider = Provider.family<AsyncValue<List<Execution>>, String?>((ref, automationId) {
  final filter = ref.watch(executionStatusFilterProvider);
  final historyAsync = ref.watch(executionHistoryProvider(automationId));

  return historyAsync.whenData((history) {
    if (filter == null) return history;
    return history.where((execution) => execution.status == filter).toList();
  });
});
