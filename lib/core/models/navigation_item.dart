import 'package:flutter/widgets.dart';

class NavigationItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String routePath;

  const NavigationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.routePath,
  });
}
