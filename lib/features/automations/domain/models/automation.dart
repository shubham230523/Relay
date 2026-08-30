import 'package:flutter/foundation.dart';

enum AutomationStatus {
  active,
  paused,
  draft,
  error,
}

@immutable
class Automation {
  final String id;
  final String name;
  final String description;
  final AutomationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastExecutedAt;
  final String? workflowId;

  const Automation({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.lastExecutedAt,
    this.workflowId,
  });

  Automation copyWith({
    String? name,
    String? description,
    AutomationStatus? status,
    DateTime? updatedAt,
    DateTime? lastExecutedAt,
    String? workflowId,
  }) {
    return Automation(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastExecutedAt: lastExecutedAt ?? this.lastExecutedAt,
      workflowId: workflowId ?? this.workflowId,
    );
  }
}
