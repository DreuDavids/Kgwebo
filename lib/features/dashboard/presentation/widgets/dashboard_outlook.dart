import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/kgwebo_colors.dart';
import '../../../../app/theme/kgwebo_spacing.dart';
import '../../../../core/money/money_formatter.dart';
import '../../../../shared/widgets/kgwebo_button.dart';
import '../../../../shared/widgets/kgwebo_pill_row.dart';
import '../../../../shared/widgets/kgwebo_section_heading.dart';
import '../../../../shared/widgets/kgwebo_soft_card.dart';
import '../../../obligations/domain/business_obligation.dart';
import '../../../obligations/domain/obligation_categories.dart';
import '../../application/dashboard_finance_controller.dart';

class DashboardOutlook extends ConsumerWidget {
  const DashboardOutlook({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardFinanceControllerProvider);
    final textTheme = Theme.of(context).textTheme;
    final outlook = state.outlook;
    final summary = state.summary;

    if (state.isPreview) {
      return const _OutlookCard(
        headline: 'Know whether cash covers what is coming.',
        body:
            'Upcoming bills will be estimates against recorded cash. They are not expenses until you record one.',
      );
    }

    if (outlook == null || summary == null) {
      return const _OutlookCard(
        headline: 'Cash-flow outlook needs saved records.',
        body:
            'When totals load, Kgwebo will list unpaid commitments without treating them as cash already spent.',
      );
    }

    final currency = outlook.currencyCode;
    final estimated = MoneyFormatter.formatMinor(
      outlook.estimatedCashAfterCommitmentsMinor,
      currencyCode: currency,
    );
    final cash = MoneyFormatter.formatMinor(
      outlook.currentCashMinor,
      currencyCode: currency,
    );
    final due = MoneyFormatter.formatMinor(
      outlook.unpaidCommitmentsMinor,
      currencyCode: currency,
    );
    final open = [...state.overdue, ...state.upcoming];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KgweboSectionHeading(
          title: 'Cash-flow outlook',
          subtitle:
              'Estimates use recorded cash and unpaid commitments. No invented sales.',
        ),
        const SizedBox(height: KgweboSpacing.sm),
        KgweboSoftCard(
          padding: const EdgeInsets.all(KgweboSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estimated cash after unpaid commitments',
                style: textTheme.labelLarge?.copyWith(
                  color: KgweboColors.inkMuted,
                ),
              ),
              const SizedBox(height: KgweboSpacing.xs),
              Text(
                estimated,
                style: textTheme.headlineSmall?.copyWith(
                  color: KgweboColors.ink,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: KgweboSpacing.sm),
              Text(
                'Estimate: recorded cash $cash minus unpaid commitments $due. '
                'This is not guaranteed future cash. Unpaid commitments are not recorded expenses and have not reduced actual cash.',
                style: textTheme.bodyMedium?.copyWith(
                  color: KgweboColors.inkMuted,
                  height: 1.5,
                ),
              ),
              if (summary.unpaidExpensesMinor != 0) ...[
                const SizedBox(height: KgweboSpacing.sm),
                Text(
                  'Recorded unpaid operating expenses ${MoneyFormatter.formatMinor(summary.unpaidExpensesMinor, currencyCode: currency)} are already in this period’s result. They are not listed again as upcoming bills.',
                  style: textTheme.bodySmall?.copyWith(
                    color: KgweboColors.inkMuted,
                    height: 1.45,
                  ),
                ),
              ],
              if (summary.unpaidSalesMinor != 0) ...[
                const SizedBox(height: KgweboSpacing.sm),
                Text(
                  'Unpaid recorded sales ${MoneyFormatter.formatMinor(summary.unpaidSalesMinor, currencyCode: currency)} are included in sales, not in cash.',
                  style: textTheme.bodySmall?.copyWith(
                    color: KgweboColors.inkMuted,
                    height: 1.45,
                  ),
                ),
              ],
              const SizedBox(height: KgweboSpacing.md),
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
          title: 'Cash-flow outlook',
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
