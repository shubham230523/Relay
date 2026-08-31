import '../../domain/models/models.dart';
import '../../domain/services/recovery_agent.dart';

class MockRecoveryAgent implements RecoveryAgent {
  @override
  Future<FailureAnalysis> analyzeFailure(Execution execution, List<ExecutionStep> steps) async {
    // Simulate AI processing time
    await Future.delayed(const Duration(seconds: 2));

    final errorMessage = execution.errorMessage?.toLowerCase() ?? '';

    if (errorMessage.contains('google sheets')) {
      return const FailureAnalysis(
        rootCause: 'Google Sheets connection expired.',
        explanation: 'Your authentication token for Google Sheets has reached its expiration limit or was revoked by the provider.',
        suggestedAction: 'Please navigate to Settings > Integrations and reconnect your Google account.',
        canAutoRecover: false,
        confidence: 0.98,
      );
    }

    if (errorMessage.contains('timeout')) {
      return const FailureAnalysis(
        rootCause: 'Network request timed out.',
        explanation: 'The external service failed to respond within the expected 30-second window.',
        suggestedAction: 'Check your internet connection or the status of the target service, then retry this step.',
        canAutoRecover: true,
        confidence: 0.85,
      );
    }

    return const FailureAnalysis(
      rootCause: 'Unknown infrastructure error.',
      explanation: 'An unexpected internal error occurred while processing this step.',
      suggestedAction: 'We recommend retrying the execution. If the problem persists, contact support.',
      canAutoRecover: true,
      confidence: 0.70,
    );
  }
}
