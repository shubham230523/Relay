import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../models/models.dart';
import '../theme/theme.dart';

class DesktopSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const DesktopSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.surfaceVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppLayout.spaceL),
            child: Row(
              children: [
                const Icon(
                  Icons.bolt,
                  color: AppColors.primary,
                  size: 32,
                ),
                const SizedBox(width: AppLayout.spaceS),
                Text(
                  'Relay',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.separated(
              itemCount: AppNavigation.mainNavigationItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppLayout.spaceXS),
              padding: const EdgeInsets.symmetric(
                horizontal: AppLayout.spaceS,
                vertical: AppLayout.spaceM,
              ),
              itemBuilder: (context, index) {
                final item = AppNavigation.mainNavigationItems[index];
                final isSelected = selectedIndex == index;

                return _SidebarItem(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => onDestinationSelected(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final NavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppLayout.buttonRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.spaceM,
          vertical: AppLayout.spaceS + AppLayout.spaceXS,
        ),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppLayout.buttonRadius),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? item.selectedIcon : item.icon,
              color: color,
              size: 24,
            ),
            const SizedBox(width: AppLayout.spaceM),
            Text(
              item.label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
