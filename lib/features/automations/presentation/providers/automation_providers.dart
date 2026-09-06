import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../executions/presentation/providers/execution_providers.dart';
import '../../../integrations/domain/models/models.dart';
import '../../../integrations/presentation/providers/integration_providers.dart';
import '../../../workflow_builder/domain/models/models.dart';
import '../../../workflow_builder/presentation/providers/workflow_builder_providers.dart';
import '../../data/repositories/empty_automation_repository.dart';
import '../../data/repositories/make_automation_repository.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/automation_repository.dart';

final automationRepositoryProvider = Provider<AutomationRepository>((ref) {
  final accounts = ref.watch(connectedAccountsProvider).value ?? [];
  final makeAccount = accounts.firstWhere(
    (a) => a.serviceType == IntegrationServiceType.make && a.accessToken != null,
    orElse: () => IntegrationAccount(
      id: '',
      email: '',
      displayName: '',
      serviceType: IntegrationServiceType.google,
      connectedAt: DateTime(2000),
    ),
  );

  if (makeAccount.id.isNotEmpty) {
    return MakeAutomationRepository(
      apiToken: makeAccount.accessToken!,
      clientId: makeAccount.clientId,
      clientSecret: makeAccount.clientSecret,
    );
  }

  return EmptyAutomationRepository();
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

class AutomationNotifier extends StateNotifier<AsyncValue<String?>> {
  final AutomationRepository _repository;
  final Ref _ref;

  AutomationNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<void> toggleStatus(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.toggleAutomationStatus(id);
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
      final automation = await _repository.getAutomationById(id);
      if (automation == null || automation.workflowId == null) {
        throw Exception('Automation or workflow not found');
      }

      final workflow = await _ref.read(workflowProvider(automation.workflowId!).future);
      if (workflow == null) throw Exception('Workflow not found');

      final executor = _ref.read(workflowExecutorProvider);
      final executionId = await executor.execute(id, workflow);
      
      state = AsyncValue.data(executionId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final automationActionsProvider = StateNotifierProvider<AutomationNotifier, AsyncValue<String?>>((ref) {
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
