import 'package:flutter/foundation.dart';

@immutable
class WorkflowEdge {
  final String id;
  final String sourceNodeId;
  final String targetNodeId;
  final String? label;

  const WorkflowEdge({
    required this.id,
    required this.sourceNodeId,
    required this.targetNodeId,
    this.label,
  });

  WorkflowEdge copyWith({
    String? sourceNodeId,
    String? targetNodeId,
    String? label,
  }) {
    return WorkflowEdge(
      id: id,
      sourceNodeId: sourceNodeId ?? this.sourceNodeId,
      targetNodeId: targetNodeId ?? this.targetNodeId,
      label: label ?? this.label,
    );
  }
}
