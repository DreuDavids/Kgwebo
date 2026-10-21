import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/kgwebo_spacing.dart';
import '../../../shared/widgets/kgwebo_wash_scaffold.dart';
import '../application/dashboard_finance_controller.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_hero.dart';
import 'widgets/dashboard_home_tabs.dart';
import 'widgets/dashboard_insights_list.dart';
import 'widgets/dashboard_metrics.dart';
import 'widgets/dashboard_notices.dart';
import 'widgets/dashboard_outlook.dart';
import 'widgets/dashboard_period_selector.dart';
import 'widgets/dashboard_pinned_sliver.dart';
import 'widgets/dashboard_quick_actions.dart';
import 'widgets/dashboard_recent.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DashboardHomeTab _tab = DashboardHomeTab.overview;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final isOverview = _tab == DashboardHomeTab.overview;

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
            const SliverToBoxAdapter(child: DashboardHeader()),
            const SliverToBoxAdapter(child: DashboardNotices()),
            if (isOverview)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: KgweboSpacing.md),
                  child: DashboardPeriodSelector(),
                ),
              ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                KgweboSpacing.md,
                isOverview ? KgweboSpacing.lg : KgweboSpacing.md,
                KgweboSpacing.md,
                KgweboSpacing.xl + bottomInset,
              ),
              sliver: SliverToBoxAdapter(child: _DashboardTabBody(tab: _tab)),
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
      DashboardHomeTab.overview => const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardHero(),
          SizedBox(height: KgweboSpacing.lg),
          DashboardMetrics(),
          SizedBox(height: KgweboSpacing.lg),
          DashboardInsightsList(),
        ],
      ),
      DashboardHomeTab.records => const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardQuickActions(),
          SizedBox(height: KgweboSpacing.lg),
          DashboardRecent(),
        ],
      ),
      DashboardHomeTab.outlook => const DashboardOutlook(),
    };
  }
}
