import '../../domain/models/models.dart';
import '../../domain/repositories/execution_repository.dart';

class EmptyExecutionRepository implements ExecutionRepository {
  @override
  Future<List<Execution>> getExecutionHistory({String? automationId}) async {
    return [];
  }

  @override
  Future<Execution?> getExecutionById(String id) async {
    return null;
  }

  @override
  Future<List<ExecutionStep>> getExecutionSteps(String executionId) async {
    return [];
  }

  @override
  Future<Execution> createExecution(Execution execution) async {
    return execution;
  }

  @override
  Future<Execution> updateExecution(Execution execution) async {
    return execution;
  }

  @override
  Future<ExecutionStep> createExecutionStep(String executionId, ExecutionStep step) async {
    return step;
  }

  @override
  Future<ExecutionStep> updateExecutionStep(String executionId, ExecutionStep step) async {
    return step;
  }

  @override
  Stream<Execution?> watchExecution(String id) {
    return Stream.value(null);
  }

  @override
  Stream<List<ExecutionStep>> watchExecutionSteps(String executionId) {
    return Stream.value([]);
  }
}
