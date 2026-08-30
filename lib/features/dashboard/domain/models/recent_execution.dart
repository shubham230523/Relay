import 'package:flutter/foundation.dart';

enum ExecutionStatus {
  success,
  failed,
  running,
  pending,
}

@immutable
class RecentExecution {
  final String id;
  final String automationName;
  final ExecutionStatus status;
  final DateTime timestamp;
  final Duration duration;

  const RecentExecution({
    required this.id,
    required this.automationName,
    required this.status,
    required this.timestamp,
    required this.duration,
  });
}
