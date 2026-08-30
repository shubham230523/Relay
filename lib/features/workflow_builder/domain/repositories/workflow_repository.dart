import '../models/models.dart';

abstract class WorkflowRepository {
  Future<Workflow> saveWorkflow(Workflow workflow);
  Future<Workflow?> getWorkflowById(String id);
}
