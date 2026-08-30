import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/constants.dart';
import '../providers/dashboard_providers.dart';
import 'automation_list_item.dart';

class RecentAutomations extends ConsumerWidget {
  const RecentAutomations({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final automationsAsync = ref.watch(dashboardAutomationsProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Automations',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Future: Navigate to full automations list
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppLayout.spaceM),
        automationsAsync.when(
          data: (automations) {
            if (automations.isEmpty) {
              return const Center(child: Text('No automations found.'));
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: automations.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppLayout.spaceS),
              itemBuilder: (context, index) {
                return AutomationListItem(automation: automations[index]);
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
