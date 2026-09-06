import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:relay/core/constants/api_constants.dart';
import '../../domain/models/automation_template.dart';
import '../../domain/repositories/template_repository.dart';
import '../../../workflow_builder/domain/models/workflow.dart';

class MakeTemplateRepository implements TemplateRepository {
  final String apiToken;
  final String baseUrl;

  MakeTemplateRepository({
    required this.apiToken,
    this.baseUrl = ApiConstants.makeBaseUrl,
  });

  Map<String, String> get _headers => {
        'Authorization': 'Token $apiToken',
        'Content-Type': 'application/json',
      };

  @override
  Future<List<AutomationTemplate>> getTemplates() async {
    // Fetching public templates
    final response = await http.get(
      Uri.parse('$baseUrl/templates/public'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List templatesJson = data['templates'] ?? [];
      return templatesJson.map((t) => _mapToTemplate(t)).toList();
    } else {
      throw Exception('Failed to load templates from Make: ${response.statusCode}');
    }
  }

  @override
  Future<AutomationTemplate?> getTemplateById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/templates/public/$id'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return _mapToTemplate(data['template']);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load template $id from Make');
    }
  }

  AutomationTemplate _mapToTemplate(Map<String, dynamic> json) {
    return AutomationTemplate(
      id: json['id'].toString(),
      name: json['name'] ?? 'Untitled Template',
      description: json['description'] ?? '',
      category: _mapCategory(json['category']),
      icon: _mapIcon(json['category']),
      workflow: Workflow(
        id: 'wf_tpl_${json['id']}',
        name: json['name'] ?? 'Untitled Workflow',
        description: json['description'] ?? '',
        nodes: [], // TODO: Map nodes from blueprint if needed
        edges: [], // TODO: Map edges from blueprint if needed
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  AutomationTemplateCategory _mapCategory(dynamic category) {
    // Basic mapping logic
    final cat = category?.toString().toLowerCase() ?? '';
    if (cat.contains('email')) return AutomationTemplateCategory.email;
    if (cat.contains('finance') || cat.contains('money')) return AutomationTemplateCategory.finance;
    if (cat.contains('productivity')) return AutomationTemplateCategory.productivity;
    if (cat.contains('business')) return AutomationTemplateCategory.business;
    if (cat.contains('ai')) return AutomationTemplateCategory.ai;
    return AutomationTemplateCategory.personal;
  }

  IconData _mapIcon(dynamic category) {
    final cat = category?.toString().toLowerCase() ?? '';
    if (cat.contains('email')) return Icons.email_outlined;
    if (cat.contains('finance')) return Icons.account_balance_wallet_outlined;
    if (cat.contains('productivity')) return Icons.check_circle_outline;
    if (cat.contains('business')) return Icons.business_center_outlined;
    if (cat.contains('ai')) return Icons.auto_awesome_outlined;
    return Icons.category_outlined;
  }
}
