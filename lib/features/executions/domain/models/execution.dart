import 'package:flutter/foundation.dart';
import 'execution_status.dart';

@immutable
class Execution {
  final String id;
  final String automationId;
  final String automationName;
  final String workflowId;
  final ExecutionStatus status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final Duration? duration;
  final String? errorMessage;

  const Execution({
    required this.id,
    required this.automationId,
    required this.automationName,
    required this.workflowId,
    required this.status,
    required this.startedAt,
    this.completedAt,
    this.duration,
    this.errorMessage,
  });

  Execution copyWith({
    ExecutionStatus? status,
    DateTime? completedAt,
    Duration? duration,
    String? errorMessage,
  }) {
    return Execution(
      id: id,
      automationId: automationId,
      automationName: automationName,
      workflowId: workflowId,
      status: status ?? this.status,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
      duration: duration ?? this.duration,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
