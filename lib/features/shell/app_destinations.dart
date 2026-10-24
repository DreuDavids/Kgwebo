import 'package:flutter/material.dart';

import '../../app/routes.dart';

/// Every top-level destination, including compact-only More.
enum AppDestination {
  dashboard,
  transactions,
  products,
  cashFlow,
  reports,
  settings,
  more,
}

extension AppDestinationX on AppDestination {
  String get path => switch (this) {
    AppDestination.dashboard => AppRoutes.dashboard,
    AppDestination.transactions => AppRoutes.transactions,
    AppDestination.products => AppRoutes.products,
    AppDestination.cashFlow => AppRoutes.cashFlow,
    AppDestination.reports => AppRoutes.reports,
    AppDestination.settings => AppRoutes.settings,
    AppDestination.more => AppRoutes.more,
  };

  String get routeName => switch (this) {
    AppDestination.dashboard => AppRoutes.dashboardName,
    AppDestination.transactions => AppRoutes.transactionsName,
    AppDestination.products => AppRoutes.productsName,
    AppDestination.cashFlow => AppRoutes.cashFlowName,
    AppDestination.reports => AppRoutes.reportsName,
    AppDestination.settings => AppRoutes.settingsName,
    AppDestination.more => AppRoutes.moreName,
  };

  String get label => switch (this) {
    AppDestination.dashboard => 'Home',
    AppDestination.transactions => 'Money',
    AppDestination.products => 'Stock',
    AppDestination.cashFlow => 'Bills',
    AppDestination.reports => 'Reports',
    AppDestination.settings => 'Settings',
    AppDestination.more => 'More',
  };

  /// Compact bar uses the same words as the rail so labels never split.
  String get compactLabel => label;

  IconData get icon => switch (this) {
    AppDestination.dashboard => Icons.dashboard_outlined,
    AppDestination.transactions => Icons.receipt_long_outlined,
    AppDestination.products => Icons.inventory_2_outlined,
    AppDestination.cashFlow => Icons.waterfall_chart_outlined,
    AppDestination.reports => Icons.description_outlined,
    AppDestination.settings => Icons.settings_outlined,
    AppDestination.more => Icons.more_horiz,
  };

  IconData get selectedIcon => switch (this) {
    AppDestination.dashboard => Icons.dashboard,
    AppDestination.transactions => Icons.receipt_long,
    AppDestination.products => Icons.inventory_2,
    AppDestination.cashFlow => Icons.waterfall_chart,
    AppDestination.reports => Icons.description,
    AppDestination.settings => Icons.settings,
    AppDestination.more => Icons.more_horiz,
  };

  int get branchIndex => index;

  bool get shownInRail => this != AppDestination.more;

  static const compactDestinations = [
    AppDestination.dashboard,
    AppDestination.transactions,
    AppDestination.products,
    AppDestination.more,
  ];

  static const railDestinations = [
    AppDestination.dashboard,
    AppDestination.transactions,
    AppDestination.products,
    AppDestination.cashFlow,
    AppDestination.reports,
    AppDestination.settings,
  ];

  static const moreDestinations = [
    AppDestination.cashFlow,
    AppDestination.reports,
    AppDestination.settings,
  ];

  static AppDestination fromBranchIndex(int index) {
    return AppDestination.values[index];
  }

  static int compactIndexFor(int branchIndex) {
    final destination = fromBranchIndex(branchIndex);
    return switch (destination) {
      AppDestination.dashboard => 0,
      AppDestination.transactions => 1,
      AppDestination.products => 2,
      AppDestination.cashFlow ||
      AppDestination.reports ||
      AppDestination.settings ||
      AppDestination.more => 3,
    };
  }
}
