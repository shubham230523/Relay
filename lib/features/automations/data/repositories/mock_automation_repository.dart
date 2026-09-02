import 'package:relay/features/automations/domain/models/models.dart';
import 'package:relay/features/automations/domain/repositories/automation_repository.dart';
import 'package:relay/features/templates/domain/models/mock_templates.dart';

class MockAutomationRepository implements AutomationRepository {
  final List<Automation> _automations = [
    Automation(
      id: '1',
      name: MockTemplates.all[0].name,
      description: MockTemplates.all[0].description,
      status: AutomationStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      lastExecutedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      workflowId: MockTemplates.all[0].workflow.id,
    ),
    Automation(
      id: '2',
      name: MockTemplates.all[1].name,
      description: MockTemplates.all[1].description,
      status: AutomationStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      lastExecutedAt: DateTime.now().subtract(const Duration(hours: 12)),
      workflowId: MockTemplates.all[1].workflow.id,
    ),
    Automation(
      id: '4',
      name: 'GitHub to Slack Sync',
      description: 'Syncs GitHub PRs to Slack channel',
      status: AutomationStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      lastExecutedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    Automation(
      id: '5',
      name: 'DB Backup',
      description: 'Daily production database backup',
      status: AutomationStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      lastExecutedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    Automation(
      id: '6',
      name: 'Customer Welcome Flow',
      description: 'Send welcome emails to new customers',
      status: AutomationStatus.paused,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Automation(
      id: '7',
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
