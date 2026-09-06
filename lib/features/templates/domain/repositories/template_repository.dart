import '../models/automation_template.dart';

abstract class TemplateRepository {
  Future<List<AutomationTemplate>> getTemplates();
  Future<AutomationTemplate?> getTemplateById(String id);
}
