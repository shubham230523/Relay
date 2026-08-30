import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/constants.dart';
import '../providers/dashboard_providers.dart';
import 'recent_execution_list_item.dart';

class RecentExecutions extends ConsumerWidget {
  const RecentExecutions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final executionsAsync = ref.watch(dashboardRecentExecutionsProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Executions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Future: Navigate to full executions history
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppLayout.spaceM),
        executionsAsync.when(
          data: (executions) {
            if (executions.isEmpty) {
              return const Center(child: Text('No executions found.'));
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: executions.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppLayout.spaceS),
              itemBuilder: (context, index) {
                return RecentExecutionListItem(execution: executions[index]);
              },
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppLayout.spaceL),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ],
    );
  }
}
