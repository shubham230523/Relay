import '../models/models.dart';

abstract class AutomationRepository {
  Future<List<Automation>> getAutomations();
  Future<Automation?> getAutomationById(String id);
  Future<Automation> createAutomation(Automation automation);
  Future<Automation> updateAutomation(Automation automation);
  Future<void> deleteAutomation(String id);
  Future<Automation> toggleAutomationStatus(String id);
}
