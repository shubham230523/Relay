import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:relay/core/constants/api_constants.dart';
import '../../domain/models/automation_template.dart';
import '../../domain/repositories/template_repository.dart';
import '../../../workflow_builder/domain/models/models.dart';

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
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/templates/public'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Make v2 uses 'templatesPublic' for the public list
        final List templatesJson = data['templatesPublic'] ?? data['templates'] ?? [];
        
        if (templatesJson.isEmpty) {
          debugPrint('Make API: No templates found in response. Keys found: ${data.keys.join(', ')}');
        }
        
        return templatesJson.map((t) => _mapToTemplate(t)).toList();
      } else {
        debugPrint('Make API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load templates from Make: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching Make templates: $e');
      rethrow;
    }
  }

  @override
  Future<AutomationTemplate?> getTemplateById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/templates/public/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _mapToTemplate(data['templatePublic'] ?? data['template'] ?? data);
      } else if (response.statusCode == 404) {
        // Fallback: If single lookup fails, try finding it in the full list
        final all = await getTemplates();
        final matches = all.where((t) => t.id == id).toList();
        return matches.isNotEmpty ? matches.first : null;
      } else {
        throw Exception('Failed to load template $id from Make');
      }
    } catch (e) {
      // Robust fallback
      final all = await getTemplates();
      final matches = all.where((t) => t.id == id).toList();
      return matches.isNotEmpty ? matches.first : null;
    }
  }

  @override
  Future<String?> getTemplateBlueprint(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/templates/public/$id/blueprint'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // The blueprint is usually in 'blueprint' or 'blueprintString'
      return data['blueprint'] ?? data['blueprintString'];
    }
    return null;
  }

  AutomationTemplate _mapToTemplate(Map<String, dynamic> json) {
    final List usedApps = json['usedApps'] ?? [];
    final appsString = usedApps.join(', ');
    final categoryInput = json['category'] ?? appsString;

    // Create simple preview nodes based on used apps
    final nodes = <WorkflowNode>[];
    for (int i = 0; i < usedApps.length; i++) {
      nodes.add(WorkflowNode(
        id: 'n$i',
        type: i == 0 ? WorkflowNodeType.trigger : WorkflowNodeType.action,
        title: usedApps[i].toString().toUpperCase(),
        description: 'Module integrated in this template.',
        position: Offset(100, 100.0 + (i * 150)),
      ));
    }

    final edges = <WorkflowEdge>[];
    for (int i = 0; i < nodes.length - 1; i++) {
      edges.add(WorkflowEdge(
        id: 'e$i',
        sourceNodeId: nodes[i].id,
        targetNodeId: nodes[i + 1].id,
      ));
    }

    return AutomationTemplate(
      id: json['id'].toString(),
      name: json['name'] ?? 'Untitled Template',
      description: json['description'] ?? '',
      category: _mapCategory(categoryInput),
      icon: _mapIcon(categoryInput),
      workflow: Workflow(
        id: 'wf_tpl_${json['id']}',
        name: json['name'] ?? 'Untitled Workflow',
        description: json['description'] ?? '',
        nodes: nodes,
        edges: edges,
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
