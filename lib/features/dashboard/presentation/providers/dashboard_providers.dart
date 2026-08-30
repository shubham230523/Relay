import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/mock_dashboard_repository.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/dashboard_repository.dart';

/// Provider for the Dashboard repository.
/// In a real app, this could be overridden to provide a real API implementation.
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return MockDashboardRepository();
});

/// Provider for the dashboard summary data.
final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getDashboardSummary();
});

/// Provider for the list of automations for the dashboard.
final dashboardAutomationsProvider = FutureProvider<List<AutomationSummary>>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getAutomations();
});

/// Provider for the list of recent executions for the dashboard.
final dashboardRecentExecutionsProvider = FutureProvider<List<RecentExecution>>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getRecentExecutions();
});
