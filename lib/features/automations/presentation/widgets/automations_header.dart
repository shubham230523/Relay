import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';

class AutomationsHeader extends StatelessWidget {
  const AutomationsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Automations',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppLayout.spaceXS),
              Text(
                'Manage and monitor your automated workflows.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  // ignore: deprecated_member_use
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppLayout.spaceM),
        ElevatedButton.icon(
          onPressed: () => context.go(AppRoutes.createAutomation),
          icon: const Icon(Icons.add),
          label: const Text('Create Automation'),
        ),
      ],
    );
  }
}
