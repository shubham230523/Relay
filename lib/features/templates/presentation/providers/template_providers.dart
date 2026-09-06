import 'package:flutter_riverpod/flutter_riverpod.dart';
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
