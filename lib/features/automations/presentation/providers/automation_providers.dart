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
