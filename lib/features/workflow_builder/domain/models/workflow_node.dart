import 'package:flutter/painting.dart';
import 'package:flutter/foundation.dart';

@immutable
class WorkflowNode {
  final String id;
  final String type;
  final String label;
  final Map<String, dynamic> data;
  final Offset position;

  const WorkflowNode({
    required this.id,
    required this.type,
    required this.label,
    this.data = const {},
    required this.position,
  });

  WorkflowNode copyWith({
    String? type,
    String? label,
    Map<String, dynamic>? data,
    Offset? position,
  }) {
    return WorkflowNode(
      id: id,
      type: type ?? this.type,
      label: label ?? this.label,
      data: data ?? this.data,
      position: position ?? this.position,
    );
  }
}
