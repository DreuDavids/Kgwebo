import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/kgwebo_colors.dart';
import '../../app/theme/kgwebo_spacing.dart';
import '../../core/finance/cash_path.dart';
import '../../core/money/money_formatter.dart';
import 'kgwebo_pill_row.dart';

/// Labelled cash path: start cash, due-date drops, end estimate, and the
/// bills that cause each drop. The line is never the only way to read values.
class KgweboCashPathChart extends StatelessWidget {
  const KgweboCashPathChart({
    super.key,
    required this.path,
    this.compact = false,
  });

  final CashPath path;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (!path.hasChart) {
      return const SizedBox.shrink();
    }

    final textTheme = Theme.of(context).textTheme;
    final currency = path.currencyCode;
    final startCash = MoneyFormatter.formatMinor(
      path.startCashMinor,
      currencyCode: currency,
    );
    final endCash = MoneyFormatter.formatMinor(
      path.endCashMinor,
      currencyCode: currency,
    );
    final maxCash = MoneyFormatter.formatMinor(
      path.maxCashMinor,
      currencyCode: currency,
    );
    final minCash = MoneyFormatter.formatMinor(
      path.minCashMinor,
      currencyCode: currency,
    );
    final startDate = DateFormat.MMMd().format(path.startDate);
    final endDate = DateFormat.MMMd().format(path.endDate);

    return Semantics(
      container: true,
      label: _summary(path),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _Endpoint(
                  label: 'Start',
                  amount: startCash,
                  date: startDate,
                ),
              ),
              const SizedBox(width: KgweboSpacing.sm),
              Expanded(
                child: _Endpoint(
                  label: 'End',
                  amount: endCash,
                  date: endDate,
                  alignEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: KgweboSpacing.sm),
          SizedBox(
            height: compact ? 112 : 132,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 76,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        maxCash,
                        style: textTheme.labelSmall?.copyWith(
                          color: KgweboColors.inkMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (path.minCashMinor != path.maxCashMinor)
                        Text(
                          minCash,
                          style: textTheme.labelSmall?.copyWith(
                            color: KgweboColors.inkMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: KgweboSpacing.xs),
                Expanded(
                  child: CustomPaint(
                    painter: _CashPathPainter(seriesMinor: path.seriesMinor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: KgweboSpacing.xs),
          Row(
            children: [
              const SizedBox(width: 84),
              Expanded(
                child: Text(
                  startDate,
                  style: textTheme.labelSmall?.copyWith(
                    color: KgweboColors.inkMuted,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  endDate,
                  textAlign: TextAlign.end,
                  style: textTheme.labelSmall?.copyWith(
                    color: KgweboColors.inkMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: KgweboSpacing.sm),
          Text(
            'Recorded cash at the start. Each drop is an unpaid bill in this ${path.horizon.label}. Not a sales forecast.',
            style: textTheme.bodySmall?.copyWith(
              color: KgweboColors.inkMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: KgweboSpacing.md),
          Text(
            'Bills in this window',
            style: textTheme.titleSmall?.copyWith(color: KgweboColors.ink),
          ),
          const SizedBox(height: KgweboSpacing.xs),
          for (final drop in path.drops)
            Padding(
              padding: const EdgeInsets.only(bottom: KgweboSpacing.xxs),
              child: KgweboPillRow(
                icon:
                    drop.isOverdue
                        ? Icons.warning_amber_outlined
                        : Icons.south_west,
                title: drop.title,
                subtitle: _dropSubtitle(drop, currency),
                trailingLabel: MoneyFormatter.formatMinor(
                  drop.amountMinor,
                  currencyCode: currency,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _dropSubtitle(CashPathDrop drop, String currency) {
    final due = DateFormat.MMMd().format(drop.dueOn);
    final after = MoneyFormatter.formatMinor(
      drop.cashAfterMinor,
      currencyCode: currency,
    );
    if (drop.isOverdue) {
      return 'Overdue · $due · leaves $after';
    }
    return '$due · leaves $after';
  }

  String _summary(CashPath path) {
    final currency = path.currencyCode;
    final start = MoneyFormatter.formatMinor(
      path.startCashMinor,
      currencyCode: currency,
    );
    final end = MoneyFormatter.formatMinor(
      path.endCashMinor,
      currencyCode: currency,
    );
    final startDate = DateFormat.yMMMd().format(path.startDate);
    final endDate = DateFormat.yMMMd().format(path.endDate);
    final drops = [
      for (final drop in path.drops)
        '${drop.title} ${MoneyFormatter.formatMinor(drop.amountMinor, currencyCode: currency)} on ${DateFormat.yMMMd().format(drop.dueOn)} leaves ${MoneyFormatter.formatMinor(drop.cashAfterMinor, currencyCode: currency)}.',
    ].join(' ');
    return 'Cash path for ${path.horizon.label}. Starts at $start on $startDate. $drops Ends at $end on $endDate. Not a sales forecast.';
  }
}

class _Endpoint extends StatelessWidget {
  const _Endpoint({
    required this.label,
    required this.amount,
    required this.date,
    this.alignEnd = false,
  });

  final String label;
  final String amount;
  final String date;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final align = alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          label,
          style: textTheme.labelLarge?.copyWith(color: KgweboColors.inkMuted),
        ),
        Text(
          amount,
          style: textTheme.titleMedium?.copyWith(color: KgweboColors.ink),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          date,
          style: textTheme.bodySmall?.copyWith(color: KgweboColors.inkMuted),
        ),
      ],
    );
  }
}

class _CashPathPainter extends CustomPainter {
  const _CashPathPainter({required this.seriesMinor});

  final List<int> seriesMinor;

  @override
  void paint(Canvas canvas, Size size) {
    if (seriesMinor.length < 2 || size.width <= 0 || size.height <= 0) {
      return;
    }

    var min = seriesMinor.first;
    var max = seriesMinor.first;
    for (final value in seriesMinor) {
      if (value < min) {
        min = value;
      }
      if (value > max) {
        max = value;
      }
    }
    final span = max - min;
    const inset = 6.0;
    final plotHeight = (size.height - inset * 2).clamp(1.0, size.height);
    final stepX = size.width / (seriesMinor.length - 1);
    Offset pointAt(int index) {
      final x = stepX * index;
      final t = span == 0 ? 0.5 : (seriesMinor[index] - min) / span;
      final y = inset + plotHeight - (t * plotHeight);
      return Offset(x, y);
    }

    final grid =
        Paint()
          ..color = KgweboColors.line
          ..strokeWidth = 1;
    canvas.drawLine(Offset(0, 0.5), Offset(size.width, 0.5), grid);
    canvas.drawLine(
      Offset(0, size.height - 0.5),
      Offset(size.width, size.height - 0.5),
      grid,
    );

    final path = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (var i = 1; i < seriesMinor.length; i++) {
      final point = pointAt(i);
      path.lineTo(point.dx, point.dy);
    }
    final line =
        Paint()
          ..color = KgweboColors.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, line);

    final fill =
        Paint()
          ..color = KgweboColors.ink
          ..style = PaintingStyle.fill;
    final dropFill =
        Paint()
          ..color = KgweboColors.lime
          ..style = PaintingStyle.fill;
    final dropStroke =
        Paint()
          ..color = KgweboColors.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    for (var i = 0; i < seriesMinor.length; i++) {
      final point = pointAt(i);
      final isDrop = i > 0 && seriesMinor[i] != seriesMinor[i - 1];
      if (isDrop) {
        canvas.drawCircle(point, 5, dropFill);
        canvas.drawCircle(point, 5, dropStroke);
      } else if (i == 0 || i == seriesMinor.length - 1) {
        canvas.drawCircle(point, 4, fill);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CashPathPainter oldDelegate) {
    return oldDelegate.seriesMinor != seriesMinor;
  }
}
