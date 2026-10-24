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
import '../../../obligations/domain/obligation_categories.dart';
import '../../application/dashboard_finance_controller.dart';
import 'cash_forecast_card.dart';

class DashboardBillsTeaser extends ConsumerWidget {
  const DashboardBillsTeaser({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardFinanceControllerProvider);
    final textTheme = Theme.of(context).textTheme;
    final forecast = state.forecast;
    final open = [...state.overdue, ...state.upcoming];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KgweboSectionHeading(
          title: 'Bills coming due',
          subtitle: 'Unpaid bills do not reduce cash until you pay them.',
        ),
        const SizedBox(height: KgweboSpacing.sm),
        if (state.isPreview)
          KgweboSoftCard(
            padding: const EdgeInsets.all(KgweboSpacing.lg),
            child: Text(
              'Sign in to see bills you still need to pay.',
              style: textTheme.bodyMedium?.copyWith(
                color: KgweboColors.inkMuted,
                height: 1.5,
              ),
            ),
          )
        else if (forecast == null)
          KgweboSoftCard(
            padding: const EdgeInsets.all(KgweboSpacing.lg),
            child: Text(
              state.loading
                  ? 'Bills will appear here after totals load.'
                  : state.error != null
                  ? 'Bills could not be loaded. This is not a zero-bills result.'
                  : 'Bills will appear here after totals load.',
              style: textTheme.bodyMedium?.copyWith(
                color: KgweboColors.inkMuted,
                height: 1.5,
              ),
            ),
          )
        else ...[
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
          const SizedBox(height: KgweboSpacing.sm),
          KgweboSoftCard(
            padding: const EdgeInsets.symmetric(vertical: KgweboSpacing.xs),
            child: Column(
              children: [
                if (open.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(KgweboSpacing.md),
                    child: Text(
                      'No unpaid bills recorded.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: KgweboColors.inkMuted,
                      ),
                    ),
                  )
                else
                  for (final item in open.take(3))
                    KgweboPillRow(
                      icon: Icons.event_outlined,
                      title: item.title,
                      subtitle:
                          '${ObligationCategories.labelFor(item.category)} · ${DateFormat.yMMMd().format(item.dueOn)}',
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
              ],
            ),
          ),
        ],
        const SizedBox(height: KgweboSpacing.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: KgweboButton(
            label: 'See bills',
            variant: KgweboButtonVariant.text,
            onPressed: () => context.goNamed(AppRoutes.cashFlowName),
          ),
        ),
      ],
    );
  }
}
