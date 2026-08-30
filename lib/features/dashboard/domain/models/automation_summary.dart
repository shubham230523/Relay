import 'package:flutter/foundation.dart';

@immutable
class AutomationSummary {
  final String id;
  final String name;
  final bool isActive;
  final DateTime? lastRun;
  final String description;

  const AutomationSummary({
    required this.id,
    required this.name,
    required this.isActive,
    this.lastRun,
    required this.description,
  });
}
