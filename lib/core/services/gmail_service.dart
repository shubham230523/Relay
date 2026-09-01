import 'package:googleapis/gmail/v1.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services.dart';

final gmailServiceProvider = Provider<GmailService>((ref) {
  final integrationService = ref.watch(integrationServiceProvider);
  return GmailService(integrationService);
});

class GmailService {
  final IntegrationService _integrationService;

  GmailService(this._integrationService);

  Future<List<Message>> listMessages({String query = ''}) async {
    final client = await _integrationService.getGoogleHttpClient();
    if (client == null) throw Exception('Google account not connected');

    try {
      final gmail = GmailApi(client);
      final response = await gmail.users.messages.list('me', q: query);
      return response.messages ?? [];
    } finally {
      client.close();
    }
  }

  Future<Message> getMessage(String id) async {
    final client = await _integrationService.getGoogleHttpClient();
    if (client == null) throw Exception('Google account not connected');

    try {
      final gmail = GmailApi(client);
      return await gmail.users.messages.get('me', id);
    } finally {
      client.close();
    }
  }
}
