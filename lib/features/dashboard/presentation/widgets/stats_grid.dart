import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/theme/theme.dart';
import '../providers/dashboard_providers.dart';
import 'stat_card.dart';

class StatsGrid extends ConsumerWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return summaryAsync.when(
      data: (summary) {
        final crossAxisCount = AppBreakpoints.isMobile(context)
            ? 1
            : AppBreakpoints.isTablet(context)
                ? 2
                : 4;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: AppLayout.spaceM,
          mainAxisSpacing: AppLayout.spaceM,
          childAspectRatio: 2.5,
          children: [
            StatCard(
              label: 'Total Automations',
              value: summary.totalAutomations.toString(),
              icon: Icons.list_alt,
            ),
            StatCard(
              label: 'Active',
              value: summary.activeAutomations.toString(),
              icon: Icons.toggle_on,
              iconColor: AppColors.success,
            ),
            StatCard(
              label: 'Successful Runs',
              value: summary.successfulExecutions.toString(),
              icon: Icons.check_circle,
              iconColor: AppColors.success,
            ),
            StatCard(
              label: 'Failed Runs',
              value: summary.failedExecutions.toString(),
              icon: Icons.error,
              iconColor: AppColors.error,
            ),
          ],
        );
      },
      loading: () => const _LoadingStatsGrid(),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

class _LoadingStatsGrid extends StatelessWidget {
  const _LoadingStatsGrid();

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = AppBreakpoints.isMobile(context)
        ? 1
        : AppBreakpoints.isTablet(context)
            ? 2
            : 4;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: AppLayout.spaceM,
      mainAxisSpacing: AppLayout.spaceM,
      childAspectRatio: 2.5,
      children: List.generate(
        4,
        (index) => const Card(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
