import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/utils/utils.dart';

class AutomationsHeader extends StatelessWidget {
  const AutomationsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = AppBreakpoints.isMobile(context);

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Automations',
          style: (isMobile ? theme.textTheme.headlineSmall : theme.textTheme.headlineMedium)?.copyWith(
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
    );

    final button = ElevatedButton.icon(
      onPressed: () => context.go(AppRoutes.createAutomation),
      icon: const Icon(Icons.add),
      label: const Text('Create Automation'),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          title,
          const SizedBox(height: AppLayout.spaceM),
          button,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: title),
        const SizedBox(width: AppLayout.spaceM),
        button,
      ],
    );
  }
}
