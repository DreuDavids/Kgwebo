import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/business_calendar.dart';
import 'package:kgwebo/core/finance/cash_outlook.dart';

void main() {
  const zone = BusinessZone.africaGaborone;
  final asOf = DateTime.utc(2026, 10, 21, 12);

  ScheduledCommitment bill({
    required String id,
    required int amount,
    required DateTime dueOn,
    CommitmentStatus status = CommitmentStatus.unpaid,
    String currency = 'BWP',
  }) {
    return ScheduledCommitment(
      id: id,
      amountMinor: amount,
      currencyCode: currency,
      dueOn: dueOn,
      status: status,
    );
  }

  test('unpaid commitments do not change recorded cash', () {
    final outlook = CashOutlookEngine.summarize(
      currentCashMinor: 255000,
      currencyCode: 'BWP',
      asOf: asOf,
      zone: zone,
      commitments: [
        bill(id: 'rent', amount: 80000, dueOn: DateTime(2026, 10, 28)),
      ],
    );

    expect(outlook.currentCashMinor, 255000);
    expect(outlook.unpaidUpcomingMinor, 80000);
    expect(outlook.overdueMinor, 0);
    expect(outlook.unpaidCommitmentsMinor, 80000);
    expect(outlook.estimatedCashAfterCommitmentsMinor, 175000);
  });

  test('overdue unpaid bills are separate from upcoming ones', () {
    final outlook = CashOutlookEngine.summarize(
      currentCashMinor: 100000,
      currencyCode: 'BWP',
      asOf: asOf,
      zone: zone,
      commitments: [
        bill(id: 'late', amount: 30000, dueOn: DateTime(2026, 10, 1)),
        bill(id: 'soon', amount: 20000, dueOn: DateTime(2026, 10, 21)),
        bill(id: 'later', amount: 40000, dueOn: DateTime(2026, 11, 1)),
      ],
    );

    expect(outlook.overdueMinor, 30000);
    expect(outlook.unpaidUpcomingMinor, 60000);
    expect(outlook.unpaidCommitmentsMinor, 90000);
    expect(outlook.estimatedCashAfterCommitmentsMinor, 10000);
  });

  test('paid and cancelled commitments are excluded from the estimate', () {
    final outlook = CashOutlookEngine.summarize(
      currentCashMinor: 50000,
      currencyCode: 'BWP',
      asOf: asOf,
      zone: zone,
      commitments: [
        bill(
          id: 'paid',
          amount: 20000,
          dueOn: DateTime(2026, 10, 30),
          status: CommitmentStatus.paid,
        ),
        bill(
          id: 'cancelled',
          amount: 15000,
          dueOn: DateTime(2026, 10, 5),
          status: CommitmentStatus.cancelled,
        ),
        bill(id: 'open', amount: 10000, dueOn: DateTime(2026, 10, 25)),
      ],
    );

    expect(outlook.unpaidCommitmentsMinor, 10000);
    expect(outlook.estimatedCashAfterCommitmentsMinor, 40000);
  });

  test('duplicate ids and mixed currency rows are skipped', () {
    final rent = bill(id: 'rent', amount: 50000, dueOn: DateTime(2026, 11, 1));
    final outlook = CashOutlookEngine.summarize(
      currentCashMinor: 80000,
      currencyCode: 'BWP',
      asOf: asOf,
      zone: zone,
      commitments: [
        rent,
        rent,
        bill(
          id: 'zar',
          amount: 20000,
          dueOn: DateTime(2026, 11, 1),
          currency: 'ZAR',
        ),
      ],
    );

    expect(outlook.unpaidCommitmentsMinor, 50000);
    expect(outlook.skippedMixedCurrency, 1);
    expect(outlook.countedCommitments, 1);
  });

  test('empty commitments leave recorded cash unchanged', () {
    final outlook = CashOutlookEngine.summarize(
      currentCashMinor: 200000,
      currencyCode: 'BWP',
      asOf: asOf,
      zone: zone,
      commitments: const [],
    );

    expect(outlook.unpaidCommitmentsMinor, 0);
    expect(outlook.estimatedCashAfterCommitmentsMinor, 200000);
    expect(outlook.countedCommitments, 0);
  });
}
