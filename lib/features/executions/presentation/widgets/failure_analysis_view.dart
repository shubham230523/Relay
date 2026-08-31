import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/theme.dart';
import '../providers/execution_providers.dart';

class FailureAnalysisView extends ConsumerWidget {
  final String executionId;

  const FailureAnalysisView({
    super.key,
    required this.executionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisAsync = ref.watch(failureAnalysisProvider(executionId));
    final theme = Theme.of(context);

    return analysisAsync.when(
      data: (analysis) {
        if (analysis == null) return const SizedBox.shrink();

        return Card(
          elevation: 0,
          // ignore: deprecated_member_use
          color: theme.colorScheme.primaryContainer.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppLayout.cardRadius),
            // ignore: deprecated_member_use
            side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppLayout.spaceM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                    const SizedBox(width: AppLayout.spaceS),
                    Text(
                      'AI FAILURE ANALYSIS',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppLayout.spaceM),
                _buildAnalysisItem(
                  context,
                  'WHAT HAPPENED?',
                  analysis.rootCause,
                ),
                const SizedBox(height: AppLayout.spaceM),
                _buildAnalysisItem(
                  context,
                  'WHY DID IT HAPPEN?',
                  analysis.explanation,
                ),
                const SizedBox(height: AppLayout.spaceM),
                _buildAnalysisItem(
                  context,
                  'SUGGESTED FIX',
                  analysis.suggestedAction,
                ),
                const SizedBox(height: AppLayout.spaceM),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Can Relay automatically recover?',
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: analysis.canAutoRecover 
                            // ignore: deprecated_member_use
                            ? AppColors.success.withOpacity(0.1)
                            // ignore: deprecated_member_use
                            : AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        analysis.canAutoRecover ? 'YES' : 'NO',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: analysis.canAutoRecover ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(AppLayout.spaceM),
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: AppLayout.spaceM),
              Text('Analyzing failure with Relay AI...'),
            ],
          ),
        ),
      ),
      error: (err, _) => Card(
        // ignore: deprecated_member_use
        color: AppColors.error.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(AppLayout.spaceM),
          child: Text('AI Analysis failed: $err', style: const TextStyle(color: AppColors.error)),
        ),
      ),
    );
  }

  Widget _buildAnalysisItem(BuildContext context, String title, String value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
