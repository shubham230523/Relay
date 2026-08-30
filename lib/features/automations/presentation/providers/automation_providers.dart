import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/mock_automation_repository.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/automation_repository.dart';

final automationRepositoryProvider = Provider<AutomationRepository>((ref) {
  return MockAutomationRepository();
});

final automationsListProvider = FutureProvider<List<Automation>>((ref) async {
  final repository = ref.watch(automationRepositoryProvider);
  return repository.getAutomations();
});

final automationSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredAutomationsProvider = Provider<AsyncValue<List<Automation>>>((ref) {
  final query = ref.watch(automationSearchQueryProvider).toLowerCase();
  final automationsAsync = ref.watch(automationsListProvider);

  return automationsAsync.whenData((automations) {
    if (query.isEmpty) return automations;
    return automations.where((automation) {
      return automation.name.toLowerCase().contains(query) ||
          automation.description.toLowerCase().contains(query);
    }).toList();
  });
});
