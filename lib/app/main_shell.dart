import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/constants.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    // Filter items for mobile bottom navigation as requested:
    // Dashboard, Automations, Executions, Settings
    final mobileItems = AppNavigation.mainNavigationItems.where((item) {
      return item.routePath == AppRoutes.dashboard ||
          item.routePath == AppRoutes.automations ||
          item.routePath == AppRoutes.executions ||
          item.routePath == AppRoutes.settings;
    }).toList();

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: mobileItems.map((item) {
          return NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}
