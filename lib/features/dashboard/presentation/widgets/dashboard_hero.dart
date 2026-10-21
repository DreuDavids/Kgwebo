import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
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
    final actions = [
      KgweboCircleAction(
        icon: Icons.add_card_outlined,
        label: 'Sale',
        emphasized: true,
        onTap: () => context.pushNamed(AppRoutes.recordSaleName),
      ),
      KgweboCircleAction(
        icon: Icons.outbox_outlined,
        label: 'Expense',
        onTap: () => context.pushNamed(AppRoutes.recordExpenseName),
      ),
      KgweboCircleAction(
        icon: Icons.receipt_long_outlined,
        label: 'Activity',
        onTap: () => context.goNamed(AppRoutes.transactionsName),
      ),
    ];

    if (state.loading && summary == null && !state.isPreview) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KgweboHeroCard(
            label: 'Your cash',
            value: '…',
            caption: 'Loading recorded cash. This is not a zero result.',
            actions: actions,
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
            label: 'Your cash',
            value: '—',
            caption:
                state.isPreview
                    ? 'Not live data. Sign in to use recorded cash.'
                    : '${state.error ?? 'Totals could not be loaded.'} This is not a zero result.',
            actions: actions,
          ),
          const SizedBox(height: 12),
          KgweboHighlightCard(
            label: 'Sales this period',
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
          label: 'Your cash',
          value: MoneyFormatter.formatMinor(
            summary.currentCashMinor,
            currencyCode: summary.currencyCode,
          ),
          caption:
              'Opening cash plus paid inflows minus paid outflows. Unpaid rows and upcoming bills are excluded.',
          actions: actions,
        ),
        const SizedBox(height: 12),
        KgweboHighlightCard(
          label: 'Sales · $period',
          value: MoneyFormatter.formatMinor(
            summary.recordedSalesMinor,
            currencyCode: summary.currencyCode,
          ),
          caption:
              'Sales in $period. Unpaid sales are included here, not in cash.',
          sparkline: state.salesSparkline,
        ),
      ],
    );
  }
}
