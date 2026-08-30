import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../workflow_builder/domain/models/models.dart';
import '../../../workflow_builder/presentation/providers/workflow_builder_providers.dart';
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

final automationDetailsProvider = FutureProvider.family<Automation?, String>((ref, id) async {
  final repository = ref.watch(automationRepositoryProvider);
  return repository.getAutomationById(id);
});

final workflowProvider = FutureProvider.family<Workflow?, String>((ref, workflowId) async {
  final repository = ref.watch(workflowRepositoryProvider);
  return repository.getWorkflowById(workflowId);
});

class AutomationNotifier extends StateNotifier<AsyncValue<void>> {
  final AutomationRepository _repository;
  final Ref _ref;

  AutomationNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<void> toggleStatus(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.toggleAutomationStatus(id);
      
      // Invalidate providers to refresh UI
      _ref.invalidate(automationsListProvider);
      _ref.invalidate(automationDetailsProvider(id));
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> runNow(String id) async {
    state = const AsyncValue.loading();
    try {
      // Simulate execution trigger delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Future: Add real execution trigger logic here
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final automationActionsProvider = StateNotifierProvider<AutomationNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(automationRepositoryProvider);
  return AutomationNotifier(repository, ref);
});

final automationSearchQueryProvider = StateProvider<String>((ref) => '');

final automationStatusFilterProvider = StateProvider<AutomationStatus?>((ref) => null);

final filteredAutomationsProvider = Provider<AsyncValue<List<Automation>>>((ref) {
  final query = ref.watch(automationSearchQueryProvider).toLowerCase();
  final statusFilter = ref.watch(automationStatusFilterProvider);
  final automationsAsync = ref.watch(automationsListProvider);

  return automationsAsync.whenData((automations) {
    return automations.where((automation) {
      final matchesQuery = query.isEmpty ||
          automation.name.toLowerCase().contains(query) ||
          automation.description.toLowerCase().contains(query);
      
      final matchesStatus = statusFilter == null || automation.status == statusFilter;
      
      return matchesQuery && matchesStatus;
    }).toList();
  });
});
