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
            subtitle: 'There are no saved figures yet.',
          ),
          SizedBox(height: 12),
          KgweboResponsiveGrid(
            children: [
              KgweboMetricCard(
                label: 'Spent',
                value: '—',
                caption: 'Sign in to record expenses.',
                icon: Icons.south_west,
                isPreview: true,
              ),
              KgweboMetricCard(
                label: 'After costs',
                value: '—',
                caption: 'Sign in to see what is left after costs.',
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
          KgweboSectionHeading(title: 'This period', subtitle: period),
          const SizedBox(height: 12),
          const KgweboResponsiveGrid(
            children: [
              KgweboMetricCard(
                label: 'Spent',
                value: '—',
                caption: 'Could not load recorded expenses.',
                icon: Icons.south_west,
              ),
              KgweboMetricCard(
                label: 'After costs',
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
        KgweboSectionHeading(title: 'This period', subtitle: period),
        const SizedBox(height: 12),
        KgweboResponsiveGrid(
          children: [
            KgweboMetricCard(
              label: 'Spent',
              value: MoneyFormatter.formatMinor(
                summary.recordedOperatingExpensesMinor,
                currencyCode: currency,
              ),
              caption:
                  'Operating costs in $period. Money you took out is not included.',
              icon: Icons.south_west,
            ),
            KgweboMetricCard(
              label: 'After costs',
              value: MoneyFormatter.formatMinor(
                summary.netRecordedOperatingResultMinor,
                currencyCode: currency,
              ),
              caption:
                  'Sales minus refunds minus costs for $period. Not cash on hand.',
              icon: Icons.insights_outlined,
            ),
          ],
        ),
      ],
    );
  }
}
