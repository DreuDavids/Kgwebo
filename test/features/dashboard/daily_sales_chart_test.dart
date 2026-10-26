import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/business_calendar.dart';
import 'package:kgwebo/core/finance/sparkline_series.dart';
import 'package:kgwebo/shared/widgets/kgwebo_daily_sales_chart.dart';
import 'package:kgwebo/shared/widgets/kgwebo_sparkline.dart';

import '../../helpers/pump_app.dart';

void main() {
  DailyBucket day({required int day, required int amount}) {
    return DailyBucket(
      startUtc: BusinessCalendar.utcFromGaborone(
        year: 2026,
        month: 10,
        day: day,
      ),
      amountMinor: amount,
    );
  }

  testWidgets('one sale day is a sentence, not a spike chart', (tester) async {
    await pumpThemed(
      tester,
      child: Scaffold(
        body: KgweboDailySalesChart(
          days: [day(day: 10, amount: 50000), day(day: 11, amount: 0)],
          currencyCode: 'BWP',
        ),
      ),
    );

    expect(find.text('Sales by day'), findsOneWidget);
    expect(find.textContaining('All of this is from Oct 10'), findsOneWidget);
    expect(
      find.textContaining('Each bar is a day with recorded sales'),
      findsNothing,
    );
    expect(find.byType(KgweboSparkline), findsNothing);
  });

  testWidgets('several sale days are labelled bars with amounts', (
    tester,
  ) async {
    await pumpThemed(
      tester,
      child: Scaffold(
        body: KgweboDailySalesChart(
          days: [
            day(day: 10, amount: 50000),
            day(day: 11, amount: 0),
            day(day: 20, amount: 20000),
          ],
          currencyCode: 'BWP',
        ),
      ),
    );

    expect(find.textContaining('2 days with sales'), findsOneWidget);
    expect(
      find.textContaining('Highest day Oct 10 · P 500.00'),
      findsOneWidget,
    );
    expect(find.text('Oct 10'), findsOneWidget);
    expect(find.text('Oct 20'), findsOneWidget);
    expect(find.text('P 500.00'), findsOneWidget);
    expect(find.text('P 200.00'), findsOneWidget);
    expect(
      find.textContaining('Each bar is a day with recorded sales'),
      findsOneWidget,
    );
  });
}
