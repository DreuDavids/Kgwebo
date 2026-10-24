import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/money/money_formatter.dart';
import '../../../../shared/widgets/kgwebo_hero_card.dart';
import '../../application/dashboard_finance_controller.dart';

class DashboardHero extends ConsumerWidget {
  const DashboardHero({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardFinanceControllerProvider);
    final summary = state.summary;
    final period =
        state.periodLabel.isEmpty ? 'this period' : state.periodLabel;

    if (state.loading && summary == null && !state.isPreview) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KgweboHeroCard(
            label: 'Cash on hand',
            value: '…',
            caption: 'Loading recorded cash. This is not a zero result.',
          ),
          const SizedBox(height: 12),
          KgweboHighlightCard(
            label: 'Sales · $period',
            value: '…',
            caption: 'Loading recorded sales for $period.',
          ),
        ],
      );
    }

    if (state.isPreview || summary == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KgweboHeroCard(
            label: 'Cash on hand',
            value: '—',
            caption:
                state.isPreview
                    ? 'Not live data. Sign in to use recorded cash.'
                    : '${state.error ?? 'Totals could not be loaded.'} This is not a zero result.',
          ),
          const SizedBox(height: 12),
          KgweboHighlightCard(
            label: 'Sales · $period',
            value: '—',
            caption:
                state.isPreview
                    ? 'Preview is not a business ledger.'
                    : 'Could not load recorded sales.',
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KgweboHeroCard(
          label: 'Cash on hand',
          value: MoneyFormatter.formatMinor(
            summary.currentCashMinor,
            currencyCode: summary.currencyCode,
          ),
          caption:
              'Opening cash plus money in, minus money out. Unpaid bills are not included.',
        ),
        const SizedBox(height: 12),
        KgweboHighlightCard(
          label: 'Sales · $period',
          value: MoneyFormatter.formatMinor(
            summary.recordedSalesMinor,
            currencyCode: summary.currencyCode,
          ),
          caption: 'Sales in $period. Unpaid sales are not cash yet.',
          sparkline: state.salesSparkline,
        ),
      ],
    );
  }
}
