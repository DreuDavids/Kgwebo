import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/kgwebo_spacing.dart';
import '../../../../shared/widgets/kgwebo_brand_mark.dart';
import '../../../../shared/widgets/kgwebo_greeting_header.dart';
import '../../../authentication/application/session_controller.dart';
import '../../../authentication/domain/app_session.dart';
import '../../application/dashboard_finance_controller.dart';
import 'dashboard_home_tabs.dart';

class DashboardBrandBar extends StatelessWidget {
  const DashboardBrandBar({super.key});

  static const double height = 64;

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        KgweboSpacing.md,
        KgweboSpacing.sm,
        KgweboSpacing.md,
        KgweboSpacing.sm,
      ),
      child: Align(alignment: Alignment.centerLeft, child: KgweboBrandMark()),
    );
  }
}

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key, this.tab = DashboardHomeTab.cash});

  final DashboardHomeTab tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider);
    final finance = ref.watch(dashboardFinanceControllerProvider);
    final businessName =
        session is AppSessionReady ? session.business.name : null;
    final subtitle = _jobSubtitle(finance, tab);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KgweboSpacing.md,
        KgweboSpacing.xs,
        KgweboSpacing.md,
        KgweboSpacing.md,
      ),
      child: KgweboGreetingHeader(
        businessName: businessName,
        subtitle: subtitle,
      ),
    );
  }

  String _jobSubtitle(DashboardFinanceState finance, DashboardHomeTab tab) {
    if (finance.isPreview) {
      return tab.job;
    }
    return switch (tab) {
      DashboardHomeTab.cash =>
        finance.summary != null && finance.summary!.countedEntries == 0
            ? 'Record your first sale.'
            : tab.job,
      DashboardHomeTab.record || DashboardHomeTab.bills => tab.job,
    };
  }
}
