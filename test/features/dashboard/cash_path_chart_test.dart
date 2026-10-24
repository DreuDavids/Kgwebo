import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/cash_forecast.dart';
import 'package:kgwebo/core/finance/cash_outlook.dart';
import 'package:kgwebo/core/finance/cash_path.dart';
import 'package:kgwebo/features/dashboard/presentation/widgets/cash_forecast_card.dart';
import 'package:kgwebo/shared/widgets/kgwebo_cash_path_chart.dart';
import 'package:kgwebo/shared/widgets/kgwebo_sparkline.dart';

import '../../helpers/pump_app.dart';

void main() {
  final asOf = DateTime.utc(2026, 10, 21, 12);

  CashForecast forecastWithBills() {
    return CashForecastEngine.project(
      currentCashMinor: 255000,
      currencyCode: 'BWP',
      asOf: asOf,
      horizon: ForecastHorizon.days7,
      commitments: [
        ScheduledCommitment(
          id: 'stock',
          amountMinor: 10000,
          currencyCode: 'BWP',
          dueOn: DateTime(2026, 10, 21),
          status: CommitmentStatus.unpaid,
        ),
        ScheduledCommitment(
          id: 'rent',
          amountMinor: 20000,
          currencyCode: 'BWP',
          dueOn: DateTime(2026, 10, 27),
          status: CommitmentStatus.unpaid,
        ),
      ],
    );
  }

  final bills = [
    CashPathBill(
      id: 'stock',
      title: 'Stock order',
      amountMinor: 10000,
      dueOn: DateTime(2026, 10, 21),
    ),
    CashPathBill(
      id: 'rent',
      title: 'Shop rent',
      amountMinor: 20000,
      dueOn: DateTime(2026, 10, 27),
    ),
  ];

  testWidgets('cash path shows start, end, dates and the bills behind drops', (
    tester,
  ) async {
    final path = CashPath.fromForecast(
      forecast: forecastWithBills(),
      bills: bills,
    );
    await pumpThemed(
      tester,
      child: Scaffold(
        body: SingleChildScrollView(child: KgweboCashPathChart(path: path)),
      ),
    );

    expect(find.text('Start'), findsOneWidget);
    expect(find.text('End'), findsOneWidget);
    expect(find.text('P 2,550.00'), findsWidgets);
    expect(find.text('P 2,250.00'), findsWidgets);
    expect(find.textContaining('Oct 21'), findsWidgets);
    expect(find.textContaining('Oct 27'), findsWidgets);
    expect(find.text('Bills in this window'), findsOneWidget);
    expect(find.text('Stock order'), findsOneWidget);
    expect(find.text('Shop rent'), findsOneWidget);
    expect(find.textContaining('Not a sales forecast'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Cash path for 7 days')),
      findsOneWidget,
    );
  });

  testWidgets('forecast card replaces the unlabelled sparkline', (
    tester,
  ) async {
    await pumpThemed(
      tester,
      size: const Size(320, 568),
      child: Scaffold(
        body: SingleChildScrollView(
          child: CashForecastCard(
            forecast: forecastWithBills(),
            bills: bills,
            compact: true,
          ),
        ),
      ),
    );

    expect(find.byType(KgweboSparkline), findsNothing);
    expect(find.byType(KgweboCashPathChart), findsOneWidget);
    expect(find.text('Stock order'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('forecast card hides the chart when there are no dated bills', (
    tester,
  ) async {
    final empty = CashForecastEngine.project(
      currentCashMinor: 255000,
      currencyCode: 'BWP',
      asOf: asOf,
      horizon: ForecastHorizon.days7,
      commitments: const [],
    );
    await pumpThemed(
      tester,
      child: Scaffold(body: CashForecastCard(forecast: empty)),
    );

    expect(find.byType(KgweboCashPathChart), findsNothing);
    expect(find.byType(KgweboSparkline), findsNothing);
    expect(find.text('Bills in this window'), findsNothing);
  });
}
