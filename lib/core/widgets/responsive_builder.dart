import 'package:flutter/widgets.dart';
import '../utils/utils.dart';

typedef ResponsiveWidgetBuilder = Widget Function(BuildContext context);

class ResponsiveBuilder extends StatelessWidget {
  final ResponsiveWidgetBuilder mobile;
  final ResponsiveWidgetBuilder? tablet;
  final ResponsiveWidgetBuilder? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final layoutType = AppBreakpoints.getLayoutType(context);

    switch (layoutType) {
      case LayoutType.desktop:
        return (desktop ?? tablet ?? mobile)(context);
      case LayoutType.tablet:
        return (tablet ?? mobile)(context);
      case LayoutType.mobile:
        return mobile(context);
    }
  }
}
