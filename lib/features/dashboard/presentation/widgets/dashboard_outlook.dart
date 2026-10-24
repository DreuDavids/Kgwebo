import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/kgwebo_colors.dart';
import '../../../../app/theme/kgwebo_spacing.dart';
import '../../../../core/finance/cash_path.dart';
import '../../../../core/money/money_formatter.dart';
import '../../../../shared/widgets/kgwebo_button.dart';
import '../../../../shared/widgets/kgwebo_pill_row.dart';
import '../../../../shared/widgets/kgwebo_section_heading.dart';
import '../../../../shared/widgets/kgwebo_soft_card.dart';
import '../../../obligations/domain/business_obligation.dart';
import '../../../obligations/domain/obligation_categories.dart';
import '../../application/dashboard_finance_controller.dart';
import 'cash_forecast_card.dart';
import 'forecast_horizon_chips.dart';

class DashboardOutlook extends ConsumerWidget {
  const DashboardOutlook({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardFinanceControllerProvider);
    final textTheme = Theme.of(context).textTheme;
    final forecast = state.forecast;
    final summary = state.summary;

    if (state.isPreview) {
      return const _OutlookCard(
        headline: 'Know whether cash covers what is coming.',
        body:
            '7, 14 and 30 day outlooks use recorded cash and unpaid commitments. They do not invent future sales.',
      );
    }

    if (forecast == null || summary == null) {
      final failedRefresh = !state.isPreview && state.error != null;
      return _OutlookCard(
        headline:
            failedRefresh
                ? 'Commitments could not be loaded.'
                : 'Cash-flow outlook needs saved records.',
        body:
            failedRefresh
                ? 'This is not a zero-bills result. Retry to load unpaid commitments; a failed refresh is not an empty list.'
                : 'When totals load, Kgwebo will list unpaid commitments without treating them as cash already spent.',
      );
    }

    final open = [...state.overdue, ...state.upcoming];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KgweboSectionHeading(
          title: 'Short-term cash outlook',
          subtitle:
              'Estimates use recorded cash and unpaid commitments. No invented sales.',
        ),
        const SizedBox(height: KgweboSpacing.sm),
        ForecastHorizonChips(
          selected: state.forecastHorizon,
          onSelected:
              (horizon) => ref
                  .read(dashboardFinanceControllerProvider.notifier)
                  .selectHorizon(horizon),
        ),
        const SizedBox(height: KgweboSpacing.md),
        CashForecastCard(
          forecast: forecast,
          compact: true,
          bills: [
            for (final item in open)
              CashPathBill(
                id: item.id,
                title: item.title,
                amountMinor: item.amountMinor,
                dueOn: item.dueOn,
              ),
          ],
        ),
        if (summary.unpaidExpensesMinor != 0) ...[
          const SizedBox(height: KgweboSpacing.sm),
          Text(
            'Recorded unpaid operating expenses ${MoneyFormatter.formatMinor(summary.unpaidExpensesMinor, currencyCode: forecast.currencyCode)} are already in this period’s result. They are not listed again as upcoming bills.',
            style: textTheme.bodySmall?.copyWith(
              color: KgweboColors.inkMuted,
              height: 1.45,
            ),
          ),
        ],
        if (summary.unpaidSalesMinor != 0) ...[
          const SizedBox(height: KgweboSpacing.sm),
          Text(
            'Unpaid recorded sales ${MoneyFormatter.formatMinor(summary.unpaidSalesMinor, currencyCode: forecast.currencyCode)} are included in sales, not in cash, and are not projected as receipts.',
            style: textTheme.bodySmall?.copyWith(
              color: KgweboColors.inkMuted,
              height: 1.45,
            ),
          ),
        ],
        const SizedBox(height: KgweboSpacing.lg),
        const KgweboSectionHeading(
          title: 'Important upcoming commitments',
          subtitle: 'Unpaid bills have not reduced recorded cash.',
        ),
        const SizedBox(height: KgweboSpacing.sm),
        KgweboSoftCard(
          padding: const EdgeInsets.all(KgweboSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (open.isEmpty)
                Text(
                  'No unpaid commitments are recorded. Add rent, supplier bills or loan repayments to see what may affect cash.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: KgweboColors.inkMuted,
                    height: 1.5,
                  ),
                )
              else
                for (final item in open.take(4))
                  Padding(
                    padding: const EdgeInsets.only(bottom: KgweboSpacing.xs),
                    child: KgweboPillRow(
                      icon: Icons.event_outlined,
                      title: item.title,
                      subtitle:
                          '${ObligationCategories.labelFor(item.category)} · ${DateFormat.yMMMd().format(item.dueOn)} · ${_statusLabel(item, state)}',
                      trailingLabel: MoneyFormatter.formatMinor(
                        item.amountMinor,
                        currencyCode: item.currencyCode,
                      ),
                      onTap:
                          () => context.pushNamed(
                            AppRoutes.obligationDetailsName,
                            pathParameters: {'obligationId': item.id},
                          ),
                    ),
                  ),
              const SizedBox(height: KgweboSpacing.sm),
              Wrap(
                spacing: KgweboSpacing.sm,
                runSpacing: KgweboSpacing.sm,
                children: [
                  KgweboButton(
                    label: 'Add a commitment',
                    onPressed:
                        () => context.pushNamed(AppRoutes.recordObligationName),
                  ),
                  KgweboButton(
                    label: 'All commitments',
                    variant: KgweboButtonVariant.text,
                    onPressed: () => context.goNamed(AppRoutes.cashFlowName),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _statusLabel(BusinessObligation item, DashboardFinanceState state) {
    if (state.overdue.any((entry) => entry.id == item.id)) {
      return 'Overdue';
    }
    return 'Unpaid';
  }
}

class _OutlookCard extends StatelessWidget {
  const _OutlookCard({required this.headline, required this.body});

  final String headline;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KgweboSectionHeading(
          title: 'Short-term cash outlook',
          subtitle: 'Forecasts will use your records, never invented sales.',
        ),
        const SizedBox(height: KgweboSpacing.sm),
        KgweboSoftCard(
          padding: const EdgeInsets.all(KgweboSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                headline,
                style: textTheme.headlineSmall?.copyWith(
                  color: KgweboColors.ink,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: KgweboSpacing.sm),
              Text(
                body,
                style: textTheme.bodyMedium?.copyWith(
                  color: KgweboColors.inkMuted,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
