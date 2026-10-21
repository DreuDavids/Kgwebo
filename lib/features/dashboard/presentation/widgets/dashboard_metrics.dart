import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/money/money_formatter.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../shared/widgets/kgwebo_loading_state.dart';
import '../../../../shared/widgets/kgwebo_metric_card.dart';
import '../../../../shared/widgets/kgwebo_section_heading.dart';
import '../../application/dashboard_finance_controller.dart';

class DashboardMetrics extends ConsumerWidget {
  const DashboardMetrics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardFinanceControllerProvider);
    final summary = state.summary;
    final period =
        state.periodLabel.isEmpty ? 'this period' : state.periodLabel;

    if (state.loading && summary == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KgweboSectionHeading(
            title: period,
            subtitle: 'Loading recorded totals.',
          ),
          const KgweboLoadingState(message: 'Loading figures'),
        ],
      );
    }

    if (state.isPreview) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KgweboSectionHeading(
            title: 'What you will track',
            subtitle: 'Local preview has no saved transactions.',
          ),
          SizedBox(height: 12),
          KgweboResponsiveGrid(
            children: [
              KgweboMetricCard(
                label: 'Expenses this period',
                value: '—',
                caption: 'Preview is not a business ledger.',
                icon: Icons.south_west,
                isPreview: true,
              ),
              KgweboMetricCard(
                label: 'Net operating result',
                value: '—',
                caption: 'Not profit. Preview has no records.',
                icon: Icons.insights_outlined,
                isPreview: true,
              ),
            ],
          ),
        ],
      );
    }

    if (summary == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KgweboSectionHeading(title: 'Recorded figures', subtitle: period),
          const SizedBox(height: 12),
          KgweboResponsiveGrid(
            children: [
              KgweboMetricCard(
                label: 'Expenses this period',
                value: '—',
                caption: 'Could not load recorded expenses.',
                icon: Icons.south_west,
              ),
              KgweboMetricCard(
                label: 'Net operating result',
                value: '—',
                caption: 'Could not load the period result.',
                icon: Icons.insights_outlined,
              ),
            ],
          ),
        ],
      );
    }

    final currency = summary.currencyCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KgweboSectionHeading(
          title: 'Recorded figures',
          subtitle:
              'Period: $period. Cash is all-time recorded cash, not this period only.',
        ),
        const SizedBox(height: 12),
        KgweboResponsiveGrid(
          children: [
            KgweboMetricCard(
              label: 'Recorded expenses',
              value: MoneyFormatter.formatMinor(
                summary.recordedOperatingExpensesMinor,
                currencyCode: currency,
              ),
              caption:
                  'Operating costs in $period. Owner withdrawals are not included.',
              icon: Icons.south_west,
            ),
            KgweboMetricCard(
              label: 'Net recorded operating result',
              value: MoneyFormatter.formatMinor(
                summary.netRecordedOperatingResultMinor,
                currencyCode: currency,
              ),
              caption:
                  'Sales minus refunds minus operating expenses for $period. Not audited profit and not cash on hand.',
              icon: Icons.insights_outlined,
            ),
            if (summary.recordedRefundsMinor != 0)
              KgweboMetricCard(
                label: 'Recorded refunds',
                value: MoneyFormatter.formatMinor(
                  summary.recordedRefundsMinor,
                  currencyCode: currency,
                ),
                caption:
                    'Customer refunds in $period. They reduce the operating result.',
                icon: Icons.replay,
              ),
          ],
        ),
      ],
    );
  }
}
