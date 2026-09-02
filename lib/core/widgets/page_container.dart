import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../utils/utils.dart';

class PageContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final bool isScrollable;
  final EdgeInsetsGeometry? padding;
  final ScrollController? scrollController;
  final AlignmentGeometry alignment;

  const PageContainer({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.isScrollable = true,
    this.padding,
    this.scrollController,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = AppBreakpoints.isMobile(context)
        ? AppLayout.screenPadding
        : AppBreakpoints.isTablet(context)
            ? AppLayout.spaceL
            : AppLayout.spaceXL;

    final effectivePadding = padding ??
        EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: AppLayout.spaceM,
        );

    Widget content = Padding(
      padding: effectivePadding,
      child: child,
    );

    if (isScrollable) {
      content = SingleChildScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: content,
      );
    }

    if (maxWidth != null) {
      content = Align(
        alignment: alignment,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth!),
          child: content,
        ),
      );
    }

    return content;
  }
}
