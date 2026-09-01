import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/integration_repository.dart';

class RealIntegrationRepository implements IntegrationRepository {
  bool _isInitialized = false;

  final List<IntegrationAccount> _accounts = [];
  final _controller = StreamController<List<IntegrationAccount>>.broadcast();

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    await GoogleSignIn.instance.initialize();
    _isInitialized = true;
  }

  @override
  Future<List<IntegrationAccount>> getConnectedAccounts() async {
    return List.unmodifiable(_accounts);
  }

  @override
  Future<IntegrationAccount> connectGoogleAccount() async {
    try {
      await _ensureInitialized();
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();

      final account = IntegrationAccount(
        id: googleUser.id,
        email: googleUser.email,
        displayName: googleUser.displayName ?? 'Google User',
        serviceType: IntegrationServiceType.google,
        connectedAt: DateTime.now(),
      );

      final index = _accounts.indexWhere((a) => a.id == account.id);
      if (index != -1) {
        _accounts[index] = account;
      } else {
        _accounts.add(account);
      }
      
      _controller.add(List.unmodifiable(_accounts));
      return account;
    } catch (e) {
      throw Exception('Failed to connect Google account: $e');
    }
  }

  @override
  Future<void> disconnectAccount(String id) async {
    final index = _accounts.indexWhere((a) => a.id == id);
    if (index != -1) {
      final account = _accounts[index];
      if (account.serviceType == IntegrationServiceType.google) {
        await GoogleSignIn.instance.signOut();
      }
      _accounts.removeAt(index);
      _controller.add(List.unmodifiable(_accounts));
    }
  }

  @override
  Stream<List<IntegrationAccount>> watchConnectedAccounts() async* {
    yield List.unmodifiable(_accounts);
    yield* _controller.stream;
  }
}
