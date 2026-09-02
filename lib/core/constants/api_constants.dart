class ApiConstants {
  ApiConstants._();

  static const String googleClientId = '696062085025-u6truuqo7s0ifm2ems1ouvrq4ahii9no.apps.googleusercontent.com';
  // GCP API Key for general services
  static const String googleApiKey = String.fromEnvironment('GCP_API_KEY', defaultValue: '');
  // Gemini API Key from Google AI Studio
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  
  static const List<String> googleScopes = [
    'email',
    'https://www.googleapis.com/auth/gmail.readonly',
    'https://www.googleapis.com/auth/spreadsheets',
  ];
}
