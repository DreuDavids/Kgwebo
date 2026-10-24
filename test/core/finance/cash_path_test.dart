import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/cash_forecast.dart';
import 'package:kgwebo/core/finance/cash_outlook.dart';
import 'package:kgwebo/core/finance/cash_path.dart';

void main() {
  final asOf = DateTime.utc(2026, 10, 21, 12);

  ScheduledCommitment bill({
    required String id,
    required int amount,
    required DateTime dueOn,
  }) {
    return ScheduledCommitment(
      id: id,
      amountMinor: amount,
      currencyCode: 'BWP',
      dueOn: dueOn,
      status: CommitmentStatus.unpaid,
    );
  }

  CashPathBill named({
    required String id,
    required String title,
    required int amount,
    required DateTime dueOn,
  }) {
    return CashPathBill(
      id: id,
      title: title,
      amountMinor: amount,
      dueOn: dueOn,
    );
  }

  CashForecast project({
    ForecastHorizon horizon = ForecastHorizon.days7,
    Iterable<ScheduledCommitment> commitments = const [],
    int cash = 255000,
  }) {
    return CashForecastEngine.project(
      currentCashMinor: cash,
      currencyCode: 'BWP',
      asOf: asOf,
      horizon: horizon,
      commitments: commitments,
    );
  }

  test(
    'path starts at recorded cash then falls on each bill in the window',
    () {
      final forecast = project(
        commitments: [
          bill(id: 'stock', amount: 10000, dueOn: DateTime(2026, 10, 21)),
          bill(id: 'rent', amount: 20000, dueOn: DateTime(2026, 10, 27)),
          bill(id: 'later', amount: 40000, dueOn: DateTime(2026, 10, 28)),
        ],
      );

      final path = CashPath.fromForecast(
        forecast: forecast,
        bills: [
          named(
            id: 'stock',
            title: 'Stock order',
            amount: 10000,
            dueOn: DateTime(2026, 10, 21),
          ),
          named(
            id: 'rent',
            title: 'Shop rent',
            amount: 20000,
            dueOn: DateTime(2026, 10, 27),
          ),
          named(
            id: 'later',
            title: 'Supplier later',
            amount: 40000,
            dueOn: DateTime(2026, 10, 28),
          ),
        ],
      );

      expect(path.hasChart, isTrue);
      expect(path.startCashMinor, 255000);
      expect(path.endCashMinor, 225000);
      expect(path.seriesMinor, [
        255000,
        245000,
        245000,
        245000,
        245000,
        245000,
        245000,
        225000,
      ]);
      expect(path.drops, hasLength(2));
      expect(path.drops.first.title, 'Stock order');
      expect(path.drops.first.cashAfterMinor, 245000);
      expect(path.drops.first.isOverdue, isFalse);
      expect(path.drops.last.title, 'Shop rent');
      expect(path.drops.last.cashAfterMinor, 225000);
    },
  );

  test('overdue bills drop cash on today and keep their original due date', () {
    final forecast = project(
      commitments: [
        bill(id: 'old', amount: 80000, dueOn: DateTime(2026, 10, 1)),
      ],
    );

    final path = CashPath.fromForecast(
      forecast: forecast,
      bills: [
        named(
          id: 'old',
          title: 'Overdue rent',
          amount: 80000,
          dueOn: DateTime(2026, 10, 1),
        ),
      ],
    );

    expect(path.drops, hasLength(1));
    expect(path.drops.single.isOverdue, isTrue);
    expect(path.drops.single.dueOn, DateTime(2026, 10, 1));
    expect(path.drops.single.cashAfterMinor, 175000);
    expect(path.seriesMinor.first, 255000);
    expect(path.seriesMinor[1], 175000);
  });

  test('no chart when the window has no dated outflows', () {
    final path = CashPath.fromForecast(forecast: project(), bills: const []);

    expect(path.hasChart, isFalse);
    expect(path.drops, isEmpty);
    expect(path.seriesMinor, isEmpty);
  });
}
