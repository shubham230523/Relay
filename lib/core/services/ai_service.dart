import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relay/core/constants/api_constants.dart';

final aiServiceProvider = Provider<AiService>((ref) {
  // Try environment variable first, then fallback to the provided Gemini key
  const apiKey = String.fromEnvironment(
    'GEMINI_API_KEY', 
    defaultValue: ApiConstants.geminiApiKey,
  );
  return AiService(apiKey);
});

class AiService {
  final String _apiKey;
  late final GenerativeModel _model;

  AiService(this._apiKey) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  bool get isAvailable => _apiKey.isNotEmpty;

  Future<String> summarize(String text) async {
    if (!isAvailable) {
      return _getSimulatedSummary(text);
    }

    try {
      final prompt = 'Summarize the following content concisely and professionally:\n\n$text';
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'Failed to generate summary.';
    } catch (e) {
      // Fallback to simulation if there's an issue with the API key or quota
      if (e.toString().contains('403') || e.toString().contains('401')) {
        return '${_getSimulatedSummary(text)}\n\n(Note: Using simulation. Please check your Gemini API key permissions.)';
      }
      return 'AI Error: ${e.toString()}';
    }
  }

  String _getSimulatedSummary(String text) {
    if (text.contains('From:')) {
      return 'I\'ve analyzed your recent emails. You have several updates regarding project deadlines and a few meeting requests. Most notably, the "Relay" project has new comments from the team.';
    }
    return 'AI Summary: The provided data focuses on automation efficiency and workflow optimization.';
  }

  Future<String> extractDetails(String text, String details) async {
    if (!isAvailable) {
      return 'AI Extraction (Simulated): { "details": "Extracted from input" } [Gemini API Key missing]';
    }

    final prompt = 'Extract the following details from the text and return as JSON: $details\n\nText: $text';
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    
    return response.text ?? 'Failed to extract details.';
  }
}
