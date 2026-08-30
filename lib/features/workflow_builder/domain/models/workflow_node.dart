import 'package:flutter/painting.dart';
import 'package:flutter/foundation.dart';

enum WorkflowNodeType {
  trigger,
  ai,
  logic,
  action,
}

@immutable
class WorkflowNode {
  final String id;
  final WorkflowNodeType type;
  final String title;
  final String description;
  final Map<String, dynamic> configuration;
  final Offset position;

  const WorkflowNode({
    required this.id,
    required this.type,
    required this.title,
    this.description = '',
    this.configuration = const {},
    required this.position,
  });

  WorkflowNode copyWith({
    WorkflowNodeType? type,
    String? title,
    String? description,
    Map<String, dynamic>? configuration,
    Offset? position,
  }) {
    return WorkflowNode(
      id: id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      configuration: configuration ?? this.configuration,
      position: position ?? this.position,
    );
  }
}
