import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good morning',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppLayout.spaceXS),
                  Text(
                    'Here is what is happening with your automations today.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      // ignore: deprecated_member_use
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppLayout.spaceM),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: () => context.go(AppRoutes.createAutomation),
                icon: const Icon(Icons.add),
                label: const Text('Create automation'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
