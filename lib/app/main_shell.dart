import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/constants.dart';
import '../core/widgets/widgets.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (context) => _MobileShell(navigationShell: navigationShell),
      tablet: (context) => _DesktopShell(navigationShell: navigationShell),
      desktop: (context) => _DesktopShell(navigationShell: navigationShell),
    );
  }
}

class _MobileShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _MobileShell({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    // Mobile items: Automations, Executions, Templates, Integrations
    final mobileItems = AppNavigation.mainNavigationItems;
    final branchIndices = List.generate(mobileItems.length, (index) => index);

    // Find if current index is in our mobile set
    int selectedIndex = navigationShell.currentIndex;
    if (selectedIndex >= mobileItems.length) selectedIndex = 0;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            branchIndices[index],
            initialLocation: branchIndices[index] == navigationShell.currentIndex,
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

class _DesktopShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _DesktopShell({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          DesktopSidebar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
          ),
          Expanded(
            child: navigationShell,
          ),
        ],
      ),
    );
  }
}
