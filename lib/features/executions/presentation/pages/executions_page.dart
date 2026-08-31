import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/execution_providers.dart';
import '../widgets/widgets.dart';

class ExecutionsPage extends ConsumerWidget {
  const ExecutionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final executionsAsync = ref.watch(filteredExecutionHistoryProvider(null));
    final theme = Theme.of(context);

    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Executions',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppLayout.spaceXS),
          Text(
            'Monitor the history of your automation runs.',
            style: theme.textTheme.bodyMedium?.copyWith(
              // ignore: deprecated_member_use
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: AppLayout.spaceL),
          const ExecutionStatusFilter(),
          const SizedBox(height: AppLayout.spaceM),
          executionsAsync.when(
            data: (executions) {
              if (executions.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppLayout.spaceXL),
                    child: Text('No executions found.'),
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: executions.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppLayout.spaceM),
                itemBuilder: (context, index) {
                  return ExecutionListItem(execution: executions[index]);
                },
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(AppLayout.spaceXL),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, st) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppLayout.spaceXL),
                child: Text('Error: $err'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
