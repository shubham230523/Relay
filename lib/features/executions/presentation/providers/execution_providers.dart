import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/mock_execution_repository.dart';
import '../../data/services/mock_workflow_execution_simulator.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/execution_repository.dart';
import '../../domain/services/services.dart';

final executionRepositoryProvider = Provider<ExecutionRepository>((ref) {
  return MockExecutionRepository();
});

final workflowExecutionSimulatorProvider = Provider<WorkflowExecutionSimulator>((ref) {
  final repo = ref.watch(executionRepositoryProvider);
  return MockWorkflowExecutionSimulator(repo);
});

final executionHistoryProvider = FutureProvider.family<List<Execution>, String?>((ref, automationId) async {
  final repo = ref.watch(executionRepositoryProvider);
  return repo.getExecutionHistory(automationId: automationId);
});

final executionDetailsProvider = FutureProvider.family<Execution?, String>((ref, id) async {
  final repo = ref.watch(executionRepositoryProvider);
  return repo.getExecutionById(id);
});

final executionStepsProvider = FutureProvider.family<List<ExecutionStep>, String>((ref, executionId) async {
  final repo = ref.watch(executionRepositoryProvider);
  return repo.getExecutionSteps(executionId);
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
