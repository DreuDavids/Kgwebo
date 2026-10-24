import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/kgwebo_spacing.dart';
import '../../../shared/widgets/kgwebo_wash_scaffold.dart';
import '../application/dashboard_finance_controller.dart';
import 'widgets/dashboard_bills_teaser.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_hero.dart';
import 'widgets/dashboard_home_tabs.dart';
import 'widgets/dashboard_metrics.dart';
import 'widgets/dashboard_notices.dart';
import 'widgets/dashboard_period_selector.dart';
import 'widgets/dashboard_pinned_sliver.dart';
import 'widgets/dashboard_recent.dart';
import 'widgets/dashboard_recommendations.dart';
import 'widgets/dashboard_record_actions.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DashboardHomeTab _tab = DashboardHomeTab.cash;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final isCash = _tab == DashboardHomeTab.cash;

    return KgweboWashScaffold(
      safeBottom: false,
      body: RefreshIndicator(
        onRefresh:
            () =>
                ref.read(dashboardFinanceControllerProvider.notifier).refresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: DashboardPinnedSliverDelegate(
                height: DashboardBrandBar.height + DashboardHomeTabs.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const DashboardBrandBar(),
                    DashboardHomeTabs(
                      selected: _tab,
                      onSelected: (tab) => setState(() => _tab = tab),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: KgweboSpacing.xl + bottomInset,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DashboardHeader(tab: _tab),
                    if (isCash) const DashboardNotices(),
                    if (isCash)
                      const Padding(
                        padding: EdgeInsets.only(top: KgweboSpacing.md),
                        child: DashboardPeriodSelector(),
                      ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        KgweboSpacing.md,
                        isCash ? KgweboSpacing.lg : KgweboSpacing.md,
                        KgweboSpacing.md,
                        0,
                      ),
                      child: _DashboardTabBody(tab: _tab),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardTabBody extends StatelessWidget {
  const _DashboardTabBody({required this.tab});

  final DashboardHomeTab tab;

  @override
  Widget build(BuildContext context) {
    return switch (tab) {
      DashboardHomeTab.cash => const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardRecordActions(),
          SizedBox(height: KgweboSpacing.lg),
          DashboardHero(),
          SizedBox(height: KgweboSpacing.lg),
          DashboardMetrics(),
          SizedBox(height: KgweboSpacing.lg),
          DashboardRecommendations(),
        ],
      ),
      DashboardHomeTab.record => const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardRecordActions(),
          SizedBox(height: KgweboSpacing.lg),
          DashboardRecent(),
        ],
      ),
      DashboardHomeTab.bills => const DashboardBillsTeaser(),
    };
  }
}
