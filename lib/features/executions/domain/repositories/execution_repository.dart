import '../models/models.dart';

abstract class ExecutionRepository {
  Future<List<Execution>> getExecutionHistory({String? automationId});
  Future<Execution?> getExecutionById(String id);
  Future<List<ExecutionStep>> getExecutionSteps(String executionId);
  Future<Execution> createExecution(Execution execution);
  Future<Execution> updateExecution(Execution execution);
  Future<ExecutionStep> createExecutionStep(String executionId, ExecutionStep step);
  Future<ExecutionStep> updateExecutionStep(String executionId, ExecutionStep step);

  Stream<Execution?> watchExecution(String id);
  Stream<List<ExecutionStep>> watchExecutionSteps(String executionId);
}
