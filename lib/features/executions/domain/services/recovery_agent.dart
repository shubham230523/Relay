import '../models/models.dart';

abstract class RecoveryAgent {
  Future<FailureAnalysis> analyzeFailure(Execution execution, List<ExecutionStep> steps);
}
