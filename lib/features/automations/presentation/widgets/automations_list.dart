import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/constants.dart';
import '../providers/automation_providers.dart';
import 'automation_card.dart';

class AutomationsList extends ConsumerWidget {
  const AutomationsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final automationsAsync = ref.watch(automationsListProvider);

    return automationsAsync.when(
      data: (automations) {
        if (automations.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppLayout.spaceXL),
              child: Column(
                children: [
                  Icon(Icons.auto_fix_off, size: 48, color: Colors.grey),
                  SizedBox(height: AppLayout.spaceM),
                  Text('No automations found'),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: automations.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppLayout.spaceM),
          itemBuilder: (context, index) {
            return AutomationCard(automation: automations[index]);
          },
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(AppLayout.spaceXL),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppLayout.spaceXL),
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
