import 'package:flutter/widgets.dart';
import '../../../workflow_builder/domain/models/models.dart';

enum AutomationTemplateCategory {
  productivity,
  email,
  finance,
  business,
  ai,
  personal,
}

@immutable
class AutomationTemplate {
  final String id;
  final String name;
  final String description;
  final AutomationTemplateCategory category;
  final Workflow workflow;
  final IconData icon;

  const AutomationTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.workflow,
    required this.icon,
  });
}
