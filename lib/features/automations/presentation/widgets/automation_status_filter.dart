import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/constants.dart';
import '../../domain/models/models.dart';
import '../providers/automation_providers.dart';

class AutomationStatusFilter extends ConsumerWidget {
  const AutomationStatusFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedStatus = ref.watch(automationStatusFilterProvider);

    return SizedBox(
      height: 48, // Fixed height for horizontal filter bar
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FilterChip(
              label: 'All',
              isSelected: selectedStatus == null,
              onTap: () => ref.read(automationStatusFilterProvider.notifier).state = null,
            ),
            const SizedBox(width: AppLayout.spaceS),
            ...AutomationStatus.values.map((status) {
              return Padding(
                padding: const EdgeInsets.only(right: AppLayout.spaceS),
                child: _FilterChip(
                  label: _getStatusLabel(status),
                  isSelected: selectedStatus == status,
                  onTap: () => ref.read(automationStatusFilterProvider.notifier).state = status,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(AutomationStatus status) {
    switch (status) {
      case AutomationStatus.active:
        return 'Active';
      case AutomationStatus.paused:
        return 'Paused';
      case AutomationStatus.draft:
        return 'Draft';
      case AutomationStatus.error:
        return 'Error';
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      // ignore: deprecated_member_use
      selectedColor: theme.colorScheme.primary.withOpacity(0.1),
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
