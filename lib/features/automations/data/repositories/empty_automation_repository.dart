import '../../domain/models/models.dart';
import '../../domain/repositories/automation_repository.dart';

class EmptyAutomationRepository implements AutomationRepository {
  @override
  Future<List<Automation>> getAutomations() async {
    return [];
  }

  @override
  Future<Automation?> getAutomationById(String id) async {
    return null;
  }

  @override
  Future<Automation> createAutomation(Automation automation) async {
    return automation;
  }

  @override
  Future<Automation> createAutomationFromTemplate({
    required String name,
    required String blueprint,
    required String templateId,
  }) async {
    throw Exception('No account connected');
  }

  @override
  Future<Automation> updateAutomation(Automation automation) async {
    return automation;
  }

  @override
  Future<void> deleteAutomation(String id) async {}

  @override
  Future<Automation> toggleAutomationStatus(String id) async {
    throw Exception('Not implemented');
  }
}
