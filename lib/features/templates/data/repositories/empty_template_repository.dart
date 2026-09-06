import '../../domain/models/automation_template.dart';
import '../../domain/repositories/template_repository.dart';

class EmptyTemplateRepository implements TemplateRepository {
  @override
  Future<List<AutomationTemplate>> getTemplates() async {
    return [];
  }

  @override
  Future<AutomationTemplate?> getTemplateById(String id) async {
    return null;
  }

  @override
  Future<String?> getTemplateBlueprint(String id) async {
    return null;
  }
}
