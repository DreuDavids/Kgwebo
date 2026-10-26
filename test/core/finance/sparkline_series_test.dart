import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/business_calendar.dart';
import 'package:kgwebo/core/finance/ledger_entry.dart';
import 'package:kgwebo/core/finance/sparkline_series.dart';

void main() {
  final october = ReportingPeriod(
    startInclusive: BusinessCalendar.utcFromGaborone(
      year: 2026,
      month: 10,
      day: 1,
    ),
    endExclusive: BusinessCalendar.utcFromGaborone(
      year: 2026,
      month: 11,
      day: 1,
    ),
  );
  final asOf = BusinessCalendar.utcFromGaborone(
    year: 2026,
    month: 10,
    day: 21,
    hour: 12,
  );

  LedgerEntry sale({
    required String id,
    required int day,
    required int amount,
  }) {
    return LedgerEntry(
      id: id,
      type: MoneyMovementType.sale,
      amountMinor: amount,
      currencyCode: 'BWP',
      occurredAt: BusinessCalendar.utcFromGaborone(
        year: 2026,
        month: 10,
        day: day,
      ),
      paymentStatus: PaymentStatus.paid,
    );
  }

  test('empty records produce no sparkline points', () {
    expect(
      SparklineSeries.dailyTotals(
        entries: const [],
        period: october,
        asOf: asOf,
        types: const {MoneyMovementType.sale},
      ),
      isEmpty,
    );
  });

  test('sales bucket by Gaborone day and skip a fake flat line', () {
    final points = SparklineSeries.dailyTotals(
      entries: [
        sale(id: 'a', day: 2, amount: 1000),
        sale(id: 'b', day: 2, amount: 500),
        sale(id: 'c', day: 10, amount: 2000),
      ],
      period: october,
      asOf: asOf,
      types: const {MoneyMovementType.sale},
    );

    expect(points.length, 21);
    expect(points[1], 1500);
    expect(points[9], 2000);
    expect(points.where((value) => value > 0).length, 2);

    final buckets = SparklineSeries.dailyBuckets(
      entries: [
        sale(id: 'a', day: 2, amount: 1000),
        sale(id: 'b', day: 2, amount: 500),
        sale(id: 'c', day: 10, amount: 2000),
      ],
      period: october,
      asOf: asOf,
      types: const {MoneyMovementType.sale},
    );
    expect(buckets.length, 21);
    expect(buckets[1].amountMinor, 1500);
    expect(
      buckets[1].startUtc,
      BusinessCalendar.utcFromGaborone(year: 2026, month: 10, day: 2),
    );
  });
}
