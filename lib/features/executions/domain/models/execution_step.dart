import 'package:flutter/foundation.dart';
import '../../../workflow_builder/domain/models/workflow_node.dart';
import 'execution_step_status.dart';

@immutable
class ExecutionStep {
  final String id;
  final String nodeId;
  final String nodeTitle;
  final WorkflowNodeType nodeType;
  final ExecutionStepStatus status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? input;
  final Map<String, dynamic>? output;
  final String? errorMessage;

  const ExecutionStep({
    required this.id,
    required this.nodeId,
    required this.nodeTitle,
    required this.nodeType,
    required this.status,
    required this.startedAt,
    this.completedAt,
    this.input,
    this.output,
    this.errorMessage,
  });

  ExecutionStep copyWith({
    ExecutionStepStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    Map<String, dynamic>? input,
    Map<String, dynamic>? output,
    String? errorMessage,
  }) {
    return ExecutionStep(
      id: id,
      nodeId: nodeId,
      nodeTitle: nodeTitle,
      nodeType: nodeType,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      input: input ?? this.input,
      output: output ?? this.output,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
