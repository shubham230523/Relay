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

  Future<List<Message>> getFullMessages(List<String> ids) async {
    final client = await _integrationService.getGoogleHttpClient();
    if (client == null) throw Exception('Google account not connected');

    try {
      final gmail = GmailApi(client);
      final List<Message> fullMessages = [];
      
      // Fetch details for the first 5 messages to avoid hitting rate limits or taking too long
      final limit = ids.length > 5 ? 5 : ids.length;
      for (int i = 0; i < limit; i++) {
        final msg = await gmail.users.messages.get('me', ids[i]);
        fullMessages.add(msg);
      }
      
      return fullMessages;
    } finally {
      client.close();
    }
  }
}
