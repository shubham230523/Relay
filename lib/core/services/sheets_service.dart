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
      
      // If no spreadsheetId is provided, we can't really guess one. 
      // For demo purposes, if it's 'default_sheet', we might log it or throw a descriptive error.
      if (spreadsheetId == 'default_sheet') {
        // In a real scenario, the user would select a sheet in the UI.
        // For now, we'll try to append to whatever ID is provided.
        // If it fails, the error will bubble up to the execution timeline.
      }

      final valueRange = ValueRange.fromJson({
        'values': [values]
      });
      
      await sheets.spreadsheets.values.append(
        valueRange,
        spreadsheetId,
        range,
        valueInputOption: 'RAW',
        insertDataOption: 'INSERT_ROWS',
      );
    } catch (e) {
      if (e.toString().contains('404')) {
        throw Exception('Spreadsheet not found. Please ensure the ID is correct and you have access.');
      }
      rethrow;
    } finally {
      client.close();
    }
  }
}
