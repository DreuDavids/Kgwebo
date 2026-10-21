import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/kgwebo_colors.dart';
import '../../../../app/theme/kgwebo_spacing.dart';
import '../../../../core/finance/cash_forecast.dart';
import '../../../../core/money/money_formatter.dart';
import '../../../../shared/widgets/kgwebo_soft_card.dart';
import '../../../../shared/widgets/kgwebo_sparkline.dart';

class CashForecastCard extends StatelessWidget {
  const CashForecastCard({
    super.key,
    required this.forecast,
    this.compact = false,
  });

  final CashForecast forecast;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currency = forecast.currencyCode;
    final estimated = MoneyFormatter.formatMinor(
      forecast.estimatedCashAfterKnownCommitmentsMinor,
      currencyCode: currency,
    );
    final cash = MoneyFormatter.formatMinor(
      forecast.currentCashMinor,
      currencyCode: currency,
    );
    final known = MoneyFormatter.formatMinor(
      forecast.overdueMinor + forecast.upcomingWithinHorizonMinor,
      currencyCode: currency,
    );
    final incoming = MoneyFormatter.formatMinor(
      forecast.expectedIncomingMinor,
      currencyCode: currency,
    );
    final insufficient =
        forecast.firstInsufficientOn == null
            ? null
            : DateFormat.yMMMd().format(forecast.firstInsufficientOn!);

    return KgweboSoftCard(
      padding: const EdgeInsets.all(KgweboSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estimated cash after known commitments',
            style: textTheme.labelLarge?.copyWith(color: KgweboColors.inkMuted),
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
            'Recorded cash $cash is unchanged. This ${forecast.horizon.label} estimate subtracts overdue bills and unpaid commitments due in the window ($known). Incoming cash is not forecast ($incoming). This is not guaranteed future cash.',
            style: textTheme.bodyMedium?.copyWith(
              color: KgweboColors.inkMuted,
              height: 1.5,
            ),
          ),
          if (insufficient != null) ...[
            const SizedBox(height: KgweboSpacing.sm),
            Text(
              'Projected cash after known bills first goes below zero on $insufficient. That date is an estimate from saved commitments only.',
              style: textTheme.bodyMedium?.copyWith(
                color: KgweboColors.ink,
                height: 1.45,
              ),
            ),
          ],
          if (forecast.hasProjectedPath) ...[
            const SizedBox(height: KgweboSpacing.md),
            KgweboSparkline(
              values: [
                for (final day in forecast.daily)
                  day.projectedCashMinor.toDouble(),
              ],
              color: KgweboColors.ink,
            ),
            const SizedBox(height: KgweboSpacing.xs),
            Text(
              'Projected cash after known commitments each day in this window. The chart is not a sales forecast.',
              style: textTheme.bodySmall?.copyWith(
                color: KgweboColors.inkMuted,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: KgweboSpacing.md),
          if (!compact) ...[
            Text(
              forecast.assumptions.first,
              style: textTheme.bodySmall?.copyWith(
                color: KgweboColors.inkMuted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: KgweboSpacing.xs),
          ],
          Text(
            'Incoming cash is not forecast. Unpaid recorded sales have no payment due date.',
            style: textTheme.bodySmall?.copyWith(
              color: KgweboColors.inkMuted,
              height: 1.45,
            ),
          ),
          for (final limitation in forecast.limitations)
            if (limitation.code != CashForecastEngine.incomingNotForecast) ...[
              const SizedBox(height: KgweboSpacing.xs),
              Text(
                limitation.message,
                style: textTheme.bodySmall?.copyWith(
                  color: KgweboColors.inkMuted,
                  height: 1.45,
                ),
              ),
            ],
        ],
      ),
    );
  }
}
