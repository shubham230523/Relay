class ApiConstants {
  ApiConstants._();

  // IMPORTANT: Replace these with your actual keys or use --dart-define
  static const String googleClientId = 'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com';
  // GCP API Key for general services
  static const String googleApiKey = 'YOUR_GOOGLE_API_KEY';
  // Gemini API Key from Google AI Studio
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
  
  static const List<String> googleScopes = [
    'email',
    'https://www.googleapis.com/auth/gmail.readonly',
    'https://www.googleapis.com/auth/spreadsheets',
  ];

  static const String makeBaseUrl = 'https://eu1.make.com/api/v2';
}
