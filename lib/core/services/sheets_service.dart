import 'package:googleapis/sheets/v4.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services.dart';

final sheetsServiceProvider = Provider<SheetsService>((ref) {
  final integrationService = ref.watch(integrationServiceProvider);
  return SheetsService(integrationService);
});

class SheetsService {
  final IntegrationService _integrationService;

  SheetsService(this._integrationService);

  Future<void> appendRow(String spreadsheetId, String range, List<Object> values) async {
    final client = await _integrationService.getGoogleHttpClient();
    if (client == null) throw Exception('Google account not connected');

    try {
      final sheets = SheetsApi(client);
      final valueRange = ValueRange.fromJson({
        'values': [values]
      });
      
      await sheets.spreadsheets.values.append(
        valueRange,
        spreadsheetId,
        range,
        valueInputOption: 'RAW',
      );
    } finally {
      client.close();
    }
  }
}
