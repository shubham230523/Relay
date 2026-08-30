import 'package:flutter/foundation.dart';
import 'workflow_node.dart';
import 'workflow_edge.dart';

@immutable
class Workflow {
  final String id;
  final String name;
  final String description;
  final List<WorkflowNode> nodes;
  final List<WorkflowEdge> edges;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Workflow({
    required this.id,
    required this.name,
    required this.description,
    required this.nodes,
    required this.edges,
    required this.createdAt,
    required this.updatedAt,
  });

  Workflow copyWith({
    String? name,
    String? description,
    List<WorkflowNode>? nodes,
    List<WorkflowEdge>? edges,
    DateTime? updatedAt,
  }) {
    return Workflow(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
