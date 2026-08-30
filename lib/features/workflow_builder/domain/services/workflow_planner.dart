import '../models/models.dart';

abstract class WorkflowPlanner {
  Future<Workflow> generateWorkflow(String userPrompt);
}
