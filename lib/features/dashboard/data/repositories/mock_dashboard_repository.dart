import '../../domain/models/mock_dashboard_data.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/dashboard_repository.dart';

class MockDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardSummary> getDashboardSummary() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockDashboardData.summary;
  }

  @override
  Future<List<AutomationSummary>> getAutomations() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return MockDashboardData.automations;
  }

  @override
  Future<List<RecentExecution>> getRecentExecutions() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return MockDashboardData.recentExecutions;
  }
}
