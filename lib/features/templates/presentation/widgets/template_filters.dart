import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/constants.dart';
import '../../domain/models/automation_template.dart';
import '../providers/template_providers.dart';

class TemplateCategoryFilter extends ConsumerWidget {
  const TemplateCategoryFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(templateCategoryFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: selectedCategory == null,
            onSelected: (_) => ref.read(templateCategoryFilterProvider.notifier).state = null,
          ),
          const SizedBox(width: AppLayout.spaceS),
          ...AutomationTemplateCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: AppLayout.spaceS),
              child: ChoiceChip(
                label: Text(_formatCategory(category)),
                selected: selectedCategory == category,
                onSelected: (_) => ref.read(templateCategoryFilterProvider.notifier).state = category,
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatCategory(AutomationTemplateCategory category) {
    final name = category.name;
    return name[0].toUpperCase() + name.substring(1);
  }
}

class TemplateSearchBar extends ConsumerWidget {
  const TemplateSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      onChanged: (value) => ref.read(templateSearchQueryProvider.notifier).state = value,
      decoration: const InputDecoration(
        hintText: 'Search templates...',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}
