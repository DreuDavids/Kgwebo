import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/kgwebo_colors.dart';
import '../../../../app/theme/kgwebo_spacing.dart';
import '../../../../core/finance/cash_forecast.dart';
import '../../../../core/finance/cash_path.dart';
import '../../../../core/money/money_formatter.dart';
import '../../../../shared/widgets/kgwebo_cash_path_chart.dart';
import '../../../../shared/widgets/kgwebo_soft_card.dart';

class CashForecastCard extends StatelessWidget {
  const CashForecastCard({
    super.key,
    required this.forecast,
    this.bills = const [],
    this.compact = false,
  });

  final CashForecast forecast;
  final Iterable<CashPathBill> bills;
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
    final knownOut =
        forecast.overdueMinor + forecast.upcomingWithinHorizonMinor;
    final known = MoneyFormatter.formatMinor(knownOut, currencyCode: currency);
    final insufficient =
        forecast.firstInsufficientOn == null
            ? null
            : DateFormat.yMMMd().format(forecast.firstInsufficientOn!);
    final billsLine =
        knownOut == 0
            ? 'No bills due in ${forecast.horizon.label}.'
            : 'Subtracts $known due in ${forecast.horizon.label}.';
    final extraLimitations = forecast.limitations.where(
      (item) => item.code != CashForecastEngine.incomingNotForecast,
    );

    return KgweboSoftCard(
      padding: const EdgeInsets.all(KgweboSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cash after known bills',
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
            '$cash recorded. $billsLine Incoming cash is not forecast.',
            style: textTheme.bodyMedium?.copyWith(
              color: KgweboColors.inkMuted,
              height: 1.45,
            ),
          ),
          if (insufficient != null) ...[
            const SizedBox(height: KgweboSpacing.sm),
            Text(
              'Projected to run out on $insufficient.',
              style: textTheme.bodyMedium?.copyWith(
                color: KgweboColors.ink,
                height: 1.45,
              ),
            ),
          ],
          if (forecast.hasProjectedPath) ...[
            const SizedBox(height: KgweboSpacing.md),
            KgweboCashPathChart(
              path: CashPath.fromForecast(forecast: forecast, bills: bills),
              compact: compact,
            ),
          ],
          for (final limitation in extraLimitations) ...[
            const SizedBox(height: KgweboSpacing.sm),
            Text(
              limitation.message,
              style: textTheme.bodySmall?.copyWith(
                color: KgweboColors.inkMuted,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
