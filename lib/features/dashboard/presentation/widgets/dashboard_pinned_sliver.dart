import 'package:flutter/material.dart';

import '../../../../app/theme/kgwebo_colors.dart';
import '../../../../app/theme/kgwebo_elevation.dart';

/// Fixed-height pinned sliver used for the home brand bar and tabs.
class DashboardPinnedSliverDelegate extends SliverPersistentHeaderDelegate {
  DashboardPinnedSliverDelegate({
    required this.height,
    required this.child,
    this.elevated = false,
  });

  final double height;
  final Widget child;
  final bool elevated;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final lift = elevated || overlapsContent || shrinkOffset > 0;
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: KgweboColors.canvas,
          boxShadow: lift ? KgweboElevation.soft : null,
        ),
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant DashboardPinnedSliverDelegate oldDelegate) {
    return height != oldDelegate.height ||
        elevated != oldDelegate.elevated ||
        child != oldDelegate.child;
  }
}
