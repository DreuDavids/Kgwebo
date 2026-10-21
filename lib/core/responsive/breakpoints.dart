import 'package:flutter/widgets.dart';

import '../../app/theme/kgwebo_spacing.dart';
import 'window_size_class.dart';

/// Width breakpoints for Kgwebo layouts.
abstract final class KgweboBreakpoints {
  static const double compactMax = 599;
  static const double mediumMax = 1023;
  static const double expandedMin = 1024;
  static const double twoColumnMin = 520;
  static const double fourColumnMin = 900;
  static const double maxContentWidth = 1120;

  static WindowSizeClass ofWidth(double width) {
    if (width <= compactMax) {
      return WindowSizeClass.compact;
    }
    if (width <= mediumMax) {
      return WindowSizeClass.medium;
    }
    return WindowSizeClass.expanded;
  }

  static WindowSizeClass of(BuildContext context) {
    return ofWidth(MediaQuery.sizeOf(context).width);
  }

  static double pagePadding(WindowSizeClass sizeClass) {
    return switch (sizeClass) {
      WindowSizeClass.compact => KgweboSpacing.compactPage,
      WindowSizeClass.medium => KgweboSpacing.mediumPage,
      WindowSizeClass.expanded => KgweboSpacing.expandedPage,
    };
  }

  static int metricColumns(double width) {
    if (width >= fourColumnMin) {
      return 4;
    }
    if (width >= twoColumnMin) {
      return 2;
    }
    return 1;
  }
}
