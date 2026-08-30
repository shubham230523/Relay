import 'package:flutter/material.dart';
import '../models/navigation_item.dart';
import 'app_routes.dart';

class AppNavigation {
  AppNavigation._();

  static const List<NavigationItem> mainNavigationItems = [
    NavigationItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      routePath: AppRoutes.dashboard,
    ),
    NavigationItem(
      label: 'Automations',
      icon: Icons.auto_fix_high_outlined,
      selectedIcon: Icons.auto_fix_high,
      routePath: AppRoutes.automations,
    ),
    NavigationItem(
      label: 'Executions',
      icon: Icons.play_circle_outline,
      selectedIcon: Icons.play_circle,
      routePath: AppRoutes.executions,
    ),
    NavigationItem(
      label: 'Templates',
      icon: Icons.copy_all_outlined,
      selectedIcon: Icons.copy_all,
      routePath: AppRoutes.templates,
    ),
    NavigationItem(
      label: 'Integrations',
      icon: Icons.extension_outlined,
      selectedIcon: Icons.extension,
      routePath: AppRoutes.integrations,
    ),
    NavigationItem(
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      routePath: AppRoutes.settings,
    ),
  ];
}
