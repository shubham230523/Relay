import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/automation_template.dart';
import '../../domain/models/mock_templates.dart';

final templatesProvider = Provider<List<AutomationTemplate>>((ref) {
  return MockTemplates.all;
});

final templateSearchQueryProvider = StateProvider<String>((ref) => '');

final templateCategoryFilterProvider = StateProvider<AutomationTemplateCategory?>((ref) => null);

final filteredTemplatesProvider = Provider<List<AutomationTemplate>>((ref) {
  final query = ref.watch(templateSearchQueryProvider).toLowerCase();
  final categoryFilter = ref.watch(templateCategoryFilterProvider);
  final allTemplates = ref.watch(templatesProvider);

  return allTemplates.where((template) {
    final matchesQuery = query.isEmpty ||
        template.name.toLowerCase().contains(query) ||
        template.description.toLowerCase().contains(query);
    
    final matchesCategory = categoryFilter == null || template.category == categoryFilter;
    
    return matchesQuery && matchesCategory;
  }).toList();
});
