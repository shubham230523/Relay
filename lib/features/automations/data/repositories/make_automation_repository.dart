import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:relay/core/constants/api_constants.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/automation_repository.dart';

class MakeAutomationRepository implements AutomationRepository {
  final String apiToken;
  final String baseUrl;
  final String? clientId;
  final String? clientSecret;
  int? _teamId;

  MakeAutomationRepository({
    required this.apiToken,
    this.baseUrl = ApiConstants.makeBaseUrl,
    this.clientId,
    this.clientSecret,
  });

  Map<String, String> get _headers => {
        'Authorization': 'Token $apiToken',
        'Content-Type': 'application/json',
      };

  Future<int> _ensureTeamId() async {
    if (_teamId != null) return _teamId!;

    // 1. Fetch organizations first
    final orgsResponse = await http.get(
      Uri.parse('$baseUrl/organizations'),
      headers: _headers,
    );

    if (orgsResponse.statusCode != 200) {
      throw Exception('Failed to fetch organizations from Make.com: ${orgsResponse.statusCode}');
    }

    final orgsData = jsonDecode(orgsResponse.body);
    final List orgs = orgsData['organizations'] ?? [];
    if (orgs.isEmpty) {
      throw Exception('No organizations found in Make.com account');
    }

    final orgId = orgs.first['id'];

    // 2. Fetch teams for that organization
    final teamsResponse = await http.get(
      Uri.parse('$baseUrl/teams?organizationId=$orgId'),
      headers: _headers,
    );

    if (teamsResponse.statusCode == 200) {
      final teamsData = jsonDecode(teamsResponse.body);
      final List teams = teamsData['teams'] ?? [];
      if (teams.isNotEmpty) {
        _teamId = teams.first['id'];
        return _teamId!;
      }
      throw Exception('No teams found in Make.com organization $orgId');
    } else {
      throw Exception('Failed to fetch teams from Make.com: ${teamsResponse.statusCode}');
    }
  }

  @override
  Future<List<Automation>> getAutomations() async {
    final teamId = await _ensureTeamId();
    final response = await http.get(
      Uri.parse('$baseUrl/scenarios?teamId=$teamId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List scenarios = data['scenarios'] ?? [];
      return scenarios.map((s) => _mapToAutomation(s)).toList();
    } else {
      throw Exception('Failed to load scenarios from Make: ${response.statusCode}');
    }
  }

  @override
  Future<Automation?> getAutomationById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/scenarios/$id'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final scenarioData = data['scenario'] ?? data;
      return _mapToAutomation(scenarioData as Map<String, dynamic>?);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load scenario $id from Make');
    }
  }

  @override
  Future<Automation> createAutomation(Automation automation) async {
    final teamId = await _ensureTeamId();

    final response = await http.post(
      Uri.parse('$baseUrl/scenarios'),
      headers: _headers,
      body: jsonEncode({
        'name': automation.name,
        'teamId': teamId,
        'blueprint': jsonEncode({
          'name': automation.name,
          'flow': [], // Empty flow for new automation
          'metadata': {
            'version': 1,
          },
        }),
        'scheduling': jsonEncode({
          'type': 'indefinitely',
          'interval': 900,
        }),
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return _mapToAutomation(data['scenario']);
    } else {
      throw Exception('Failed to create scenario in Make: ${response.body}');
    }
  }

  Future<int?> _findGoogleConnectionId(int teamId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/connections?teamId=$teamId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List connections = data['connections'] ?? [];
      for (var conn in connections) {
        final accountName = conn['accountName']?.toString().toLowerCase() ?? '';
        if (accountName == 'google' || accountName == 'google-restricted') {
          return conn['id'];
        }
      }
    }
    return null;
  }

  Future<int> _createGoogleConnection(int teamId) async {
    if (clientId == null || clientSecret == null) {
      throw Exception('Google Client ID and Secret are required to create a connection.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/connections'),
      headers: _headers,
      body: jsonEncode({
        'name': 'Relay Google Connection',
        'teamId': teamId,
        'accountName': 'google-restricted', // Standard for Gmail/Sheets
        'clientId': clientId,
        'clientSecret': clientSecret,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['connection']['id'];
    } else {
      throw Exception('Failed to create Google connection in Make: ${response.body}');
    }
  }

  @override
  Future<Automation> createAutomationFromTemplate({
    required String name,
    required String blueprint,
    required String templateId,
  }) async {
    final teamId = await _ensureTeamId();

    // 1. Try to find or create a Google connection
    int? connectionId = await _findGoogleConnectionId(teamId);
    if (connectionId == null && clientId != null && clientSecret != null) {
      connectionId = await _createGoogleConnection(teamId);
      // Note: This connection will need authorization via Make UI or OAuth flow
      debugPrint('Created new Google connection with ID: $connectionId. It may need authorization.');
    }

    // 2. Inject connection ID into blueprint if found
    String finalBlueprint = blueprint;
    if (connectionId != null) {
      finalBlueprint = blueprint.replaceAll(RegExp(r'"__IMTCONN__":\s*\d+'), '"__IMTCONN__": $connectionId');
      finalBlueprint = finalBlueprint.replaceAll(RegExp(r'"__IMTCONN__":\s*null'), '"__IMTCONN__": $connectionId');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/scenarios'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'teamId': teamId,
        'blueprint': finalBlueprint,
        'basedon': int.tryParse(templateId),
        'scheduling': jsonEncode({
          'type': 'indefinitely',
          'interval': 900,
        }),
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final scenarioData = data['scenario'] ?? data;
      return _mapToAutomation(scenarioData as Map<String, dynamic>?);
    } else {
      throw Exception('Failed to create scenario from template in Make: ${response.body}');
    }
  }

  @override
  Future<Automation> updateAutomation(Automation automation) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/scenarios/${automation.id}'),
      headers: _headers,
      body: jsonEncode({
        'name': automation.name,
        // Update blueprint if needed
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final scenarioData = data['scenario'] ?? data;
      return _mapToAutomation(scenarioData as Map<String, dynamic>?);
    } else {
      throw Exception('Failed to update scenario in Make');
    }
  }

  @override
  Future<void> deleteAutomation(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/scenarios/$id'),
      headers: _headers,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete scenario in Make');
    }
  }

  @override
  Future<Automation> toggleAutomationStatus(String id) async {
    final current = await getAutomationById(id);
    if (current == null) throw Exception('Automation not found');

    final newActive = current.status != AutomationStatus.active;
    
    final response = await http.patch(
      Uri.parse('$baseUrl/scenarios/$id'),
      headers: _headers,
      body: jsonEncode({
        'active': newActive,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final scenarioData = data['scenario'] ?? data;
      return _mapToAutomation(scenarioData as Map<String, dynamic>?);
    } else {
      throw Exception('Failed to toggle status in Make');
    }
  }

  Automation _mapToAutomation(Map<String, dynamic>? json) {
    if (json == null) {
      throw Exception('Received null scenario data from Make.com');
    }

    // Safely parse dates with fallbacks
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    return Automation(
      id: (json['id'] ?? 'unknown').toString(),
      name: json['name'] ?? 'Untitled',
      description: json['description'] ?? '',
      status: _mapStatus(json['active'], json['draft']),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      lastExecutedAt: json['lastRun'] != null ? parseDate(json['lastRun']) : null,
      workflowId: (json['id'] ?? '').toString(),
    );
  }

  AutomationStatus _mapStatus(bool? active, bool? draft) {
    if (draft == true) return AutomationStatus.draft;
    if (active == true) return AutomationStatus.active;
    return AutomationStatus.paused;
  }
}
