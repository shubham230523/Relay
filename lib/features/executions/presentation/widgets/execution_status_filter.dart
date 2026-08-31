import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/constants.dart';
import '../../domain/models/models.dart';
import '../providers/execution_providers.dart';

class ExecutionStatusFilter extends ConsumerWidget {
  const ExecutionStatusFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedStatus = ref.watch(executionStatusFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isSelected: selectedStatus == null,
            onTap: () => ref.read(executionStatusFilterProvider.notifier).state = null,
          ),
          const SizedBox(width: AppLayout.spaceS),
          ...[
            ExecutionStatus.running,
            ExecutionStatus.success,
            ExecutionStatus.failed,
            ExecutionStatus.cancelled,
          ].map((status) {
            return Padding(
              padding: const EdgeInsets.only(right: AppLayout.spaceS),
              child: _FilterChip(
                label: _getStatusLabel(status),
                isSelected: selectedStatus == status,
                onTap: () => ref.read(executionStatusFilterProvider.notifier).state = status,
              ),
            );
          }),
        ],
      ),
    );
  }

  String _getStatusLabel(ExecutionStatus status) {
    switch (status) {
      case ExecutionStatus.pending:
        return 'Pending';
      case ExecutionStatus.running:
        return 'Running';
      case ExecutionStatus.success:
        return 'Success';
      case ExecutionStatus.failed:
        return 'Failed';
      case ExecutionStatus.cancelled:
        return 'Cancelled';
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
