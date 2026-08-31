import 'package:flutter/foundation.dart';

@immutable
class FailureAnalysis {
  final String rootCause;
  final String explanation;
  final String suggestedAction;
  final bool canAutoRecover;
  final double confidence;

  const FailureAnalysis({
    required this.rootCause,
    required this.explanation,
    required this.suggestedAction,
    required this.canAutoRecover,
    required this.confidence,
  });
}
