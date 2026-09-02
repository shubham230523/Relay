import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relay/core/constants/api_constants.dart';

final integrationServiceProvider = Provider<IntegrationService>((ref) {
  return IntegrationService();
});

class IntegrationService {
  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    await GoogleSignIn.instance.initialize(
      clientId: ApiConstants.googleClientId,
    );
    _isInitialized = true;
  }

  Future<auth.AuthClient?> getGoogleHttpClient() async {
    await _ensureInitialized();
    
    final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.attemptLightweightAuthentication();
    if (googleUser == null) return null;

    final authorization = await googleUser.authorizationClient.authorizeScopes(ApiConstants.googleScopes);
    return authorization.authClient(scopes: ApiConstants.googleScopes);
  }
}
