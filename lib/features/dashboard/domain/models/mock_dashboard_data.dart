import 'models.dart';

class MockDashboardData {
  MockDashboardData._();

  static const summary = DashboardSummary(
    totalAutomations: 12,
    activeAutomations: 8,
    successfulExecutions: 145,
    failedExecutions: 3,
  );

  static final recentExecutions = [
    RecentExecution(
      id: '1',
      automationName: 'Sync GitHub to Slack',
      status: ExecutionStatus.success,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      duration: const Duration(seconds: 12),
    ),
    RecentExecution(
      id: '2',
      automationName: 'Backup Database',
      status: ExecutionStatus.failed,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      duration: const Duration(minutes: 2),
    ),
    RecentExecution(
      id: '3',
      automationName: 'Daily Report Generator',
      status: ExecutionStatus.success,
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      duration: const Duration(seconds: 45),
    ),
    RecentExecution(
      id: '4',
      automationName: 'Web Scraper Job',
      status: ExecutionStatus.running,
      timestamp: DateTime.now(),
      duration: const Duration(seconds: 5),
    ),
  ];

  static final automations = [
    const AutomationSummary(
      id: 'a1',
      name: 'Sync GitHub to Slack',
      isActive: true,
      description: 'Automatically posts GitHub PR updates to the #dev-channel.',
    ),
    const AutomationSummary(
      id: 'a2',
      name: 'Backup Database',
      isActive: true,
      description: 'Daily midnight backup of the production PostgreSQL database.',
    ),
    const AutomationSummary(
      id: 'a3',
      name: 'Welcome Email',
      isActive: false,
      description: 'Sends a welcome email sequence to new users.',
    ),
  ];
}
