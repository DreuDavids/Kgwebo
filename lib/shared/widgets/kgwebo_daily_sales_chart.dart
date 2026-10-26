import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/kgwebo_colors.dart';
import '../../app/theme/kgwebo_radii.dart';
import '../../app/theme/kgwebo_spacing.dart';
import '../../core/finance/business_calendar.dart';
import '../../core/finance/sparkline_series.dart';
import '../../core/money/money_formatter.dart';

/// Labelled sales-by-day readout. Quiet days are omitted so a single sale
/// never becomes an unreadable spike chart. The line is never the only way
/// to read the values.
class KgweboDailySalesChart extends StatelessWidget {
  const KgweboDailySalesChart({
    super.key,
    required this.days,
    required this.currencyCode,
    this.maxDays = 7,
    this.foreground = KgweboColors.ink,
  });

  final List<DailyBucket> days;
  final String currencyCode;
  final int maxDays;
  final Color foreground;

  static List<DailyBucket> saleDays(List<DailyBucket> days) {
    return [
      for (final day in days)
        if (day.amountMinor > 0) day,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final sales = saleDays(days);
    if (sales.isEmpty) {
      return const SizedBox.shrink();
    }

    final textTheme = Theme.of(context).textTheme;
    final visible =
        sales.length <= maxDays ? sales : sales.sublist(sales.length - maxDays);
    final highest = _highest(sales);
    final summary = _summary(
      sales: sales,
      visible: visible,
      highest: highest,
      currencyCode: currencyCode,
    );

    return Semantics(
      container: true,
      label: summary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sales by day',
            style: textTheme.labelLarge?.copyWith(color: foreground),
          ),
          const SizedBox(height: KgweboSpacing.xs),
          Text(
            summary,
            style: textTheme.bodySmall?.copyWith(
              color: foreground,
              height: 1.35,
            ),
          ),
          if (visible.length >= 2) ...[
            const SizedBox(height: KgweboSpacing.sm),
            for (final day in visible)
              Padding(
                padding: const EdgeInsets.only(top: KgweboSpacing.xs),
                child: _SaleDayBar(
                  day: day,
                  maxMinor: highest.amountMinor,
                  currencyCode: currencyCode,
                  foreground: foreground,
                ),
              ),
            const SizedBox(height: KgweboSpacing.xs),
            Text(
              'Each bar is a day with recorded sales. Quiet days are left off.',
              style: textTheme.bodySmall?.copyWith(
                color: foreground,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static DailyBucket _highest(List<DailyBucket> sales) {
    var best = sales.first;
    for (final day in sales.skip(1)) {
      if (day.amountMinor > best.amountMinor) {
        best = day;
      }
    }
    return best;
  }

  static String _summary({
    required List<DailyBucket> sales,
    required List<DailyBucket> visible,
    required DailyBucket highest,
    required String currencyCode,
  }) {
    final highestLabel =
        '${_date(highest.startUtc)} · ${MoneyFormatter.formatMinor(highest.amountMinor, currencyCode: currencyCode)}';
    if (sales.length == 1) {
      return 'All of this is from ${_date(sales.first.startUtc)}.';
    }
    if (visible.length < sales.length) {
      return 'Latest ${visible.length} of ${sales.length} days with sales. Highest day $highestLabel.';
    }
    return '${sales.length} days with sales. Highest day $highestLabel.';
  }

  static String _date(DateTime startUtc) {
    return DateFormat.MMMd().format(
      BusinessCalendar.gaboroneWallTime(startUtc),
    );
  }
}

class _SaleDayBar extends StatelessWidget {
  const _SaleDayBar({
    required this.day,
    required this.maxMinor,
    required this.currencyCode,
    required this.foreground,
  });

  final DailyBucket day;
  final int maxMinor;
  final String currencyCode;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final t = maxMinor <= 0 ? 0.0 : day.amountMinor / maxMinor;
    final widthFactor = t < 0.08 ? 0.08 : t;
    final date = KgweboDailySalesChart._date(day.startUtc);
    final amount = MoneyFormatter.formatMinor(
      day.amountMinor,
      currencyCode: currencyCode,
    );

    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(
            date,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(color: foreground),
          ),
        ),
        const SizedBox(width: KgweboSpacing.xs),
        Expanded(
          child: ClipRRect(
            borderRadius: KgweboRadii.borderPill,
            child: ColoredBox(
              color: foreground.withValues(alpha: 0.16),
              child: SizedBox(
                height: 10,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: widthFactor,
                  child: ColoredBox(color: foreground),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: KgweboSpacing.xs),
        Text(amount, style: textTheme.labelSmall?.copyWith(color: foreground)),
      ],
    );
  }
}
