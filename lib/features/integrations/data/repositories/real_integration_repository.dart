import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:relay/core/constants/api_constants.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/integration_repository.dart';

class RealIntegrationRepository implements IntegrationRepository {
  bool _isInitialized = false;
  static const String _storageKey = 'connected_accounts';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final List<IntegrationAccount> _accounts = [];
  final _controller = StreamController<List<IntegrationAccount>>.broadcast();

  RealIntegrationRepository();

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    try {
      // Load persisted accounts first
      await _loadAccounts();

      // Only initialize Google Sign-In on supported platforms
      if (kIsWeb || defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
        await GoogleSignIn.instance.initialize(
          clientId: ApiConstants.googleClientId,
        );
      }
      _isInitialized = true;
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('already-initialized') || errorStr.contains('already_initialized')) {
        _isInitialized = true;
        return;
      }
      debugPrint('Initialization Warning (non-fatal): $e');
      // We still mark as initialized so we don't keep retrying failing components
      _isInitialized = true;
    }
  }

  Future<void> _loadAccounts() async {
    try {
      final jsonStr = await _storage.read(key: _storageKey);
      if (jsonStr != null) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        _accounts.clear();
        _accounts.addAll(decoded.map((item) => IntegrationAccount.fromJson(item)));
        _controller.add(List.unmodifiable(_accounts));
      }
    } catch (e) {
      debugPrint('Error loading accounts: $e');
    }
  }

  Future<void> _saveAccounts() async {
    try {
      final jsonStr = jsonEncode(_accounts.map((a) => a.toJson()).toList());
      await _storage.write(key: _storageKey, value: jsonStr);
    } catch (e) {
      debugPrint('Error saving accounts: $e');
    }
  }

  @override
  Future<List<IntegrationAccount>> getConnectedAccounts() async {
    await _ensureInitialized();
    return List.unmodifiable(_accounts);
  }

  @override
  Future<IntegrationAccount> connectGoogleAccount() async {
    try {
      await _ensureInitialized();
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate(
        scopeHint: ApiConstants.googleScopes,
      );

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
      
      await _saveAccounts();
      _controller.add(List.unmodifiable(_accounts));
      return account;
    } catch (e) {
      throw Exception('Failed to connect Google account: $e');
    }
  }

  @override
  Future<IntegrationAccount> connectMakeAccount(
    String apiToken,
    String clientId,
    String clientSecret,
  ) async {
    await _ensureInitialized();
    // In a real app, you might validate the token with a simple API call here
    final account = IntegrationAccount(
      id: 'make_${apiToken.hashCode}', // Unique enough for identification
      email: 'API Token User', // Make doesn't easily expose user email via token alone without extra calls
      displayName: 'Make.com',
      serviceType: IntegrationServiceType.make,
      connectedAt: DateTime.now(),
      accessToken: apiToken,
      clientId: clientId,
      clientSecret: clientSecret,
    );

    final index = _accounts.indexWhere((a) => a.id == account.id);
    if (index != -1) {
      _accounts[index] = account;
    } else {
      _accounts.add(account);
    }

    await _saveAccounts();
    _controller.add(List.unmodifiable(_accounts));
    return account;
  }

  @override
  Future<void> disconnectAccount(String id) async {
    await _ensureInitialized();
    final index = _accounts.indexWhere((a) => a.id == id);
    if (index != -1) {
      final account = _accounts[index];
      if (account.serviceType == IntegrationServiceType.google) {
        await GoogleSignIn.instance.signOut();
      }
      _accounts.removeAt(index);
      await _saveAccounts();
      _controller.add(List.unmodifiable(_accounts));
    }
  }

  @override
  Stream<List<IntegrationAccount>> watchConnectedAccounts() async* {
    await _ensureInitialized();
    yield List.unmodifiable(_accounts);
    yield* _controller.stream;
  }
}
