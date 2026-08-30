import 'package:flutter/widgets.dart';

enum LayoutType {
  mobile,
  tablet,
  desktop,
}

class AppBreakpoints {
  AppBreakpoints._();

  static const double mobileMax = 600.0;
  static const double tabletMax = 1024.0;

  static LayoutType getLayoutType(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    if (width < mobileMax) {
      return LayoutType.mobile;
    } else if (width <= tabletMax) {
      return LayoutType.tablet;
    } else {
      return LayoutType.desktop;
    }
  }

  static bool isMobile(BuildContext context) =>
      getLayoutType(context) == LayoutType.mobile;

  static bool isTablet(BuildContext context) =>
      getLayoutType(context) == LayoutType.tablet;

  static bool isDesktop(BuildContext context) =>
      getLayoutType(context) == LayoutType.desktop;

  static bool isMobileOrTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width <= tabletMax;
}
