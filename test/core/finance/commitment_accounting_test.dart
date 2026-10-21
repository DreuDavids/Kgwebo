import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/business_calendar.dart';
import 'package:kgwebo/core/finance/cash_outlook.dart';
import 'package:kgwebo/core/finance/financial_engine.dart';
import 'package:kgwebo/core/finance/ledger_entry.dart';

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

  LedgerEntry expense({
    required String id,
    required int amount,
    PaymentStatus status = PaymentStatus.paid,
  }) {
    return LedgerEntry(
      id: id,
      type: MoneyMovementType.expense,
      amountMinor: amount,
      currencyCode: 'BWP',
      occurredAt: BusinessCalendar.utcFromGaborone(
        year: 2026,
        month: 10,
        day: 10,
      ),
      paymentStatus: status,
    );
  }

  ScheduledCommitment rent({
    required CommitmentStatus status,
    int amount = 80000,
  }) {
    return ScheduledCommitment(
      id: 'rent',
      amountMinor: amount,
      currencyCode: 'BWP',
      dueOn: DateTime(2026, 10, 28),
      status: status,
    );
  }

  test(
    'unpaid commitment is not an operating expense and does not reduce cash',
    () {
      final summary = FinancialEngine.summarize(
        entries: const [],
        openingCashMinor: 200000,
        currencyCode: 'BWP',
        period: october,
        asOf: asOf,
      );
      final outlook = CashOutlookEngine.summarize(
        currentCashMinor: summary.currentCashMinor,
        currencyCode: summary.currencyCode,
        asOf: asOf,
        zone: BusinessZone.africaGaborone,
        commitments: [rent(status: CommitmentStatus.unpaid)],
      );

      expect(summary.recordedSalesMinor, 0);
      expect(summary.recordedOperatingExpensesMinor, 0);
      expect(summary.netRecordedOperatingResultMinor, 0);
      expect(summary.currentCashMinor, 200000);
      expect(outlook.currentCashMinor, 200000);
      expect(outlook.unpaidCommitmentsMinor, 80000);
      expect(outlook.estimatedCashAfterCommitmentsMinor, 120000);
    },
  );

  test('marking a commitment paid does not itself create an expense', () {
    final summary = FinancialEngine.summarize(
      entries: const [],
      openingCashMinor: 200000,
      currencyCode: 'BWP',
      period: october,
      asOf: asOf,
    );
    final outlook = CashOutlookEngine.summarize(
      currentCashMinor: summary.currentCashMinor,
      currencyCode: summary.currencyCode,
      asOf: asOf,
      zone: BusinessZone.africaGaborone,
      commitments: [rent(status: CommitmentStatus.paid)],
    );

    expect(summary.recordedOperatingExpensesMinor, 0);
    expect(summary.netRecordedOperatingResultMinor, 0);
    expect(summary.currentCashMinor, 200000);
    expect(outlook.unpaidCommitmentsMinor, 0);
    expect(outlook.estimatedCashAfterCommitmentsMinor, 200000);
  });

  test(
    'recording the matching expense does not double-count the paid commitment',
    () {
      final summary = FinancialEngine.summarize(
        entries: [expense(id: 'rent-paid', amount: 80000)],
        openingCashMinor: 200000,
        currencyCode: 'BWP',
        period: october,
        asOf: asOf,
      );
      final outlook = CashOutlookEngine.summarize(
        currentCashMinor: summary.currentCashMinor,
        currencyCode: summary.currencyCode,
        asOf: asOf,
        zone: BusinessZone.africaGaborone,
        commitments: [rent(status: CommitmentStatus.paid)],
      );

      expect(summary.recordedOperatingExpensesMinor, 80000);
      expect(summary.netRecordedOperatingResultMinor, -80000);
      expect(summary.currentCashMinor, 120000);
      expect(outlook.unpaidCommitmentsMinor, 0);
      expect(outlook.estimatedCashAfterCommitmentsMinor, 120000);
    },
  );
}
