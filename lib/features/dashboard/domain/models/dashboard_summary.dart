import 'package:flutter/foundation.dart';

@immutable
class DashboardSummary {
  final int totalAutomations;
  final int activeAutomations;
  final int successfulExecutions;
  final int failedExecutions;

  const DashboardSummary({
    required this.totalAutomations,
    required this.activeAutomations,
    required this.successfulExecutions,
    required this.failedExecutions,
  });

  double get successRate {
    final total = successfulExecutions + failedExecutions;
    if (total == 0) return 0.0;
    return (successfulExecutions / total) * 100;
  }
}
