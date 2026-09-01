import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/real_integration_repository.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/repositories.dart';

final integrationRepositoryProvider = Provider<IntegrationRepository>((ref) {
  return RealIntegrationRepository();
});

final connectedAccountsProvider = StreamProvider<List<IntegrationAccount>>((ref) {
  final repo = ref.watch(integrationRepositoryProvider);
  return repo.watchConnectedAccounts();
});

class IntegrationActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final IntegrationRepository _repository;

  IntegrationActionsNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> connectGoogle() async {
    state = const AsyncValue.loading();
    try {
      await _repository.connectGoogleAccount();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> disconnect(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.disconnectAccount(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final integrationActionsProvider =
    StateNotifierProvider<IntegrationActionsNotifier, AsyncValue<void>>((ref) {
  final repo = ref.watch(integrationRepositoryProvider);
  return IntegrationActionsNotifier(repo);
});
