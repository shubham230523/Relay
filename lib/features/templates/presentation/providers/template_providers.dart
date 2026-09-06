import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../automations/domain/models/models.dart';
import '../../../automations/domain/repositories/automation_repository.dart';
import '../../../automations/presentation/providers/automation_providers.dart';
import '../../../integrations/domain/models/models.dart';
import '../../../integrations/presentation/providers/integration_providers.dart';
import '../../data/repositories/empty_template_repository.dart';
import '../../data/repositories/make_template_repository.dart';
import '../../domain/models/automation_template.dart';
import '../../domain/repositories/template_repository.dart';

final templateRepositoryProvider = Provider<TemplateRepository>((ref) {
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
    return MakeTemplateRepository(apiToken: makeAccount.accessToken!);
  }

  return EmptyTemplateRepository();
});

final templatesProvider = FutureProvider<List<AutomationTemplate>>((ref) async {
  final repository = ref.watch(templateRepositoryProvider);
  return repository.getTemplates();
});

final templateDetailsProvider = FutureProvider.family<AutomationTemplate?, String>((ref, id) async {
  // 1. Try to find in the already loaded list first (fast & reliable)
  final allTemplatesAsync = ref.read(templatesProvider);
  if (allTemplatesAsync.hasValue) {
    final cached = allTemplatesAsync.value!.where((t) => t.id == id).toList();
    if (cached.isNotEmpty) return cached.first;
  }

  // 2. If not found or list not loaded, fetch from repository
  final repository = ref.watch(templateRepositoryProvider);
  return repository.getTemplateById(id);
});

final templateSearchQueryProvider = StateProvider<String>((ref) => '');

final templateCategoryFilterProvider = StateProvider<AutomationTemplateCategory?>((ref) => null);

final filteredTemplatesProvider = Provider<AsyncValue<List<AutomationTemplate>>>((ref) {
  final query = ref.watch(templateSearchQueryProvider).toLowerCase();
  final categoryFilter = ref.watch(templateCategoryFilterProvider);
  final templatesAsync = ref.watch(templatesProvider);

  return templatesAsync.whenData((templates) {
    return templates.where((template) {
      final matchesQuery = query.isEmpty ||
          template.name.toLowerCase().contains(query) ||
          template.description.toLowerCase().contains(query);
      
      final matchesCategory = categoryFilter == null || template.category == categoryFilter;
      
      return matchesQuery && matchesCategory;
    }).toList();
  });
});

class TemplateActionsNotifier extends StateNotifier<AsyncValue<Automation?>> {
  final TemplateRepository _templateRepo;
  final AutomationRepository _automationRepo;
  final Ref _ref;

  TemplateActionsNotifier(this._templateRepo, this._automationRepo, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> createFromTemplate(AutomationTemplate template) async {
    state = const AsyncValue.loading();
    try {
      final blueprint = await _templateRepo.getTemplateBlueprint(template.id);
      if (blueprint == null) throw Exception('Could not fetch template blueprint');

      final automation = await _automationRepo.createAutomationFromTemplate(
        name: template.name,
        blueprint: blueprint,
        templateId: template.id,
      );

      _ref.invalidate(automationsListProvider);
      state = AsyncValue.data(automation);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final templateActionsProvider =
    StateNotifierProvider<TemplateActionsNotifier, AsyncValue<Automation?>>((ref) {
  final templateRepo = ref.watch(templateRepositoryProvider);
  final automationRepo = ref.watch(automationRepositoryProvider);
  return TemplateActionsNotifier(templateRepo, automationRepo, ref);
});
