import '../../domain/models/models.dart';
import '../../domain/repositories/automation_repository.dart';

class MockAutomationRepository implements AutomationRepository {
  final List<Automation> _automations = [
    Automation(
      id: '1',
      name: 'GitHub to Slack Sync',
      description: 'Syncs GitHub PRs to Slack channel',
      status: AutomationStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      lastExecutedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    Automation(
      id: '2',
      name: 'DB Backup',
      description: 'Daily production database backup',
      status: AutomationStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      lastExecutedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    Automation(
      id: '3',
      name: 'Customer Welcome Flow',
      description: 'Send welcome emails to new customers',
      status: AutomationStatus.paused,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Automation(
      id: '4',
      name: 'Error Monitor',
      description: 'Notifies team on production errors',
      status: AutomationStatus.error,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Future<List<Automation>> getAutomations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_automations);
  }

  @override
  Future<Automation?> getAutomationById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _automations.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Automation> createAutomation(Automation automation) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _automations.add(automation);
    return automation;
  }

  @override
  Future<Automation> updateAutomation(Automation automation) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _automations.indexWhere((a) => a.id == automation.id);
    if (index != -1) {
      _automations[index] = automation;
      return automation;
    }
    throw Exception('Automation not found');
  }

  @override
  Future<void> deleteAutomation(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _automations.removeWhere((a) => a.id == id);
  }

  @override
  Future<Automation> toggleAutomationStatus(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _automations.indexWhere((a) => a.id == id);
    if (index != -1) {
      final automation = _automations[index];
      final newStatus = automation.status == AutomationStatus.active
          ? AutomationStatus.paused
          : AutomationStatus.active;
      
      final updated = automation.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
      _automations[index] = updated;
      return updated;
    }
    throw Exception('Automation not found');
  }
}
