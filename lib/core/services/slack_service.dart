import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final slackServiceProvider = Provider<SlackService>((ref) {
  return SlackService();
});

class SlackService {
  Future<void> sendMessage(String webhookUrl, String text) async {
    final response = await http.post(
      Uri.parse(webhookUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send Slack message: ${response.body}');
    }
  }
}
