import '../models/models.dart';

abstract class DashboardRepository {
  Future<DashboardSummary> getDashboardSummary();
  Future<List<AutomationSummary>> getAutomations();
  Future<List<RecentExecution>> getRecentExecutions();
}
