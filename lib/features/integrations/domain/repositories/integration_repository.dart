import '../models/models.dart';

abstract class IntegrationRepository {
  Future<List<IntegrationAccount>> getConnectedAccounts();
  Future<IntegrationAccount> connectGoogleAccount();
  Future<void> disconnectAccount(String id);
  Stream<List<IntegrationAccount>> watchConnectedAccounts();
}
