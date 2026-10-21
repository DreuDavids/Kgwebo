import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/business_calendar.dart';
import 'package:kgwebo/core/finance/finance_exception.dart';
import 'package:kgwebo/core/finance/financial_engine.dart';
import 'package:kgwebo/core/finance/ledger_entry.dart';
import 'package:kgwebo/core/money/money_limits.dart';

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

  LedgerEntry entry({
    required String id,
    required MoneyMovementType type,
    required int amount,
    DateTime? occurredAt,
    PaymentStatus status = PaymentStatus.paid,
    String currency = 'BWP',
  }) {
    return LedgerEntry(
      id: id,
      type: type,
      amountMinor: amount,
      currencyCode: currency,
      occurredAt:
          occurredAt ??
          BusinessCalendar.utcFromGaborone(year: 2026, month: 10, day: 10),
      paymentStatus: status,
    );
  }

  test('spec cash fixture excludes owner flows from sales and expenses', () {
    final summary = FinancialEngine.summarize(
      entries: [
        entry(id: 'sale', type: MoneyMovementType.sale, amount: 50000),
        entry(id: 'exp', type: MoneyMovementType.expense, amount: 10000),
        entry(
          id: 'in',
          type: MoneyMovementType.ownerContribution,
          amount: 20000,
        ),
        entry(id: 'out', type: MoneyMovementType.ownerWithdrawal, amount: 5000),
      ],
      openingCashMinor: 200000,
      currencyCode: 'BWP',
      period: october,
      asOf: asOf,
    );

    expect(summary.recordedSalesMinor, 50000);
    expect(summary.recordedOperatingExpensesMinor, 10000);
    expect(summary.netRecordedOperatingResultMinor, 40000);
    expect(summary.currentCashMinor, 255000);
    expect(summary.openingCashMinor, isNot(summary.recordedSalesMinor));
  });

  test('empty period keeps opening cash and zeros the period totals', () {
    final summary = FinancialEngine.summarize(
      entries: const [],
      openingCashMinor: 200000,
      currencyCode: 'BWP',
      period: october,
      asOf: asOf,
    );

    expect(summary.recordedSalesMinor, 0);
    expect(summary.recordedOperatingExpensesMinor, 0);
    expect(summary.netRecordedOperatingResultMinor, 0);
    expect(summary.currentCashMinor, 200000);
    expect(summary.countedEntries, 0);
  });

  test('includes the first and last instants of the period', () {
    final start = entry(
      id: 'start',
      type: MoneyMovementType.sale,
      amount: 100,
      occurredAt: october.startInclusive,
    );
    final lastInstant = entry(
      id: 'end',
      type: MoneyMovementType.sale,
      amount: 200,
      occurredAt: october.endExclusive.subtract(
        const Duration(microseconds: 1),
      ),
    );
    final after = entry(
      id: 'after',
      type: MoneyMovementType.sale,
      amount: 400,
      occurredAt: october.endExclusive,
    );

    final summary = FinancialEngine.summarize(
      entries: [start, lastInstant, after],
      openingCashMinor: 0,
      currencyCode: 'BWP',
      period: october,
      asOf: october.endExclusive.add(const Duration(days: 1)),
    );

    expect(summary.recordedSalesMinor, 300);
    expect(summary.currentCashMinor, 700);
  });

  test('period crossing a year boundary stays exclusive at the end', () {
    final period = ReportingPeriod(
      startInclusive: BusinessCalendar.utcFromGaborone(
        year: 2026,
        month: 12,
        day: 31,
      ),
      endExclusive: BusinessCalendar.utcFromGaborone(
        year: 2027,
        month: 1,
        day: 2,
      ),
    );
    final summary = FinancialEngine.summarize(
      entries: [
        entry(
          id: 'nye',
          type: MoneyMovementType.sale,
          amount: 1000,
          occurredAt: BusinessCalendar.utcFromGaborone(
            year: 2026,
            month: 12,
            day: 31,
            hour: 23,
          ),
        ),
        entry(
          id: 'new-year',
          type: MoneyMovementType.expense,
          amount: 250,
          occurredAt: BusinessCalendar.utcFromGaborone(
            year: 2027,
            month: 1,
            day: 1,
          ),
        ),
        entry(
          id: 'after',
          type: MoneyMovementType.sale,
          amount: 8000,
          occurredAt: BusinessCalendar.utcFromGaborone(
            year: 2027,
            month: 1,
            day: 2,
          ),
        ),
      ],
      openingCashMinor: 0,
      currencyCode: 'BWP',
      period: period,
      asOf: BusinessCalendar.utcFromGaborone(year: 2027, month: 1, day: 3),
    );

    expect(summary.recordedSalesMinor, 1000);
    expect(summary.recordedOperatingExpensesMinor, 250);
    expect(summary.netRecordedOperatingResultMinor, 750);
  });

  test('duplicate ids are counted once', () {
    final sale = entry(id: 'dup', type: MoneyMovementType.sale, amount: 50000);
    final summary = FinancialEngine.summarize(
      entries: [sale, sale],
      openingCashMinor: 0,
      currencyCode: 'BWP',
      period: october,
      asOf: asOf,
    );

    expect(summary.recordedSalesMinor, 50000);
    expect(summary.countedEntries, 1);
  });

  test('mixed currencies are excluded from the total', () {
    final summary = FinancialEngine.summarize(
      entries: [
        entry(id: 'bwp', type: MoneyMovementType.sale, amount: 10000),
        entry(
          id: 'zar',
          type: MoneyMovementType.sale,
          amount: 20000,
          currency: 'ZAR',
        ),
      ],
      openingCashMinor: 0,
      currencyCode: 'BWP',
      period: october,
      asOf: asOf,
    );

    expect(summary.recordedSalesMinor, 10000);
    expect(summary.skippedMixedCurrency, 1);
    expect(summary.countedEntries, 1);
  });

  test('invalid amounts are rejected', () {
    expect(
      () => FinancialEngine.summarize(
        entries: [entry(id: 'zero', type: MoneyMovementType.sale, amount: 0)],
        openingCashMinor: 0,
        currencyCode: 'BWP',
        period: october,
        asOf: asOf,
      ),
      throwsA(isA<FinanceException>()),
    );
    expect(
      () => FinancialEngine.summarize(
        entries: [entry(id: 'neg', type: MoneyMovementType.sale, amount: -100)],
        openingCashMinor: 0,
        currencyCode: 'BWP',
        period: october,
        asOf: asOf,
      ),
      throwsA(isA<FinanceException>()),
    );
  });

  test('integer overflow of a total is rejected', () {
    expect(
      () => FinancialEngine.summarize(
        entries: [entry(id: 'huge', type: MoneyMovementType.sale, amount: 1)],
        openingCashMinor: MoneyLimits.maxSignedTotal,
        currencyCode: 'BWP',
        period: october,
        asOf: asOf,
      ),
      throwsA(isA<FinanceException>()),
    );
  });

  test('unpaid sales and expenses do not move cash', () {
    final summary = FinancialEngine.summarize(
      entries: [
        entry(
          id: 'credit-sale',
          type: MoneyMovementType.sale,
          amount: 80000,
          status: PaymentStatus.unpaid,
        ),
        entry(
          id: 'bill',
          type: MoneyMovementType.expense,
          amount: 30000,
          status: PaymentStatus.unpaid,
        ),
        entry(id: 'cash-sale', type: MoneyMovementType.sale, amount: 10000),
      ],
      openingCashMinor: 5000,
      currencyCode: 'BWP',
      period: october,
      asOf: asOf,
    );

    expect(summary.recordedSalesMinor, 90000);
    expect(summary.recordedOperatingExpensesMinor, 30000);
    expect(summary.netRecordedOperatingResultMinor, 60000);
    expect(summary.currentCashMinor, 15000);
    expect(summary.unpaidSalesMinor, 80000);
    expect(summary.unpaidExpensesMinor, 30000);
  });

  test('refunds reduce recorded sales and paid cash', () {
    final summary = FinancialEngine.summarize(
      entries: [
        entry(id: 'sale', type: MoneyMovementType.sale, amount: 50000),
        entry(id: 'refund', type: MoneyMovementType.refund, amount: 20000),
      ],
      openingCashMinor: 0,
      currencyCode: 'BWP',
      period: october,
      asOf: asOf,
    );

    expect(summary.recordedSalesMinor, 50000);
    expect(summary.recordedRefundsMinor, 20000);
    expect(summary.netRecordedSalesMinor, 30000);
    expect(summary.netRecordedOperatingResultMinor, 30000);
    expect(summary.currentCashMinor, 30000);
  });

  test('negative operating result is represented directly', () {
    final summary = FinancialEngine.summarize(
      entries: [
        entry(id: 'sale', type: MoneyMovementType.sale, amount: 1000),
        entry(id: 'exp', type: MoneyMovementType.expense, amount: 4000),
      ],
      openingCashMinor: 0,
      currencyCode: 'BWP',
      period: october,
      asOf: asOf,
    );

    expect(summary.netRecordedOperatingResultMinor, -3000);
  });

  test('0.10 + 0.20 thebe arithmetic stays exact', () {
    final summary = FinancialEngine.summarize(
      entries: [
        entry(id: 'a', type: MoneyMovementType.sale, amount: 10),
        entry(id: 'b', type: MoneyMovementType.sale, amount: 20),
      ],
      openingCashMinor: 0,
      currencyCode: 'BWP',
      period: october,
      asOf: asOf,
    );

    expect(summary.recordedSalesMinor, 30);
  });

  test(
    'last-month period excludes this-month sales but cash stays all-time',
    () {
      final september = BusinessCalendar.previousMonth(asOf);
      final summary = FinancialEngine.summarize(
        entries: [
          entry(
            id: 'sep-sale',
            type: MoneyMovementType.sale,
            amount: 40000,
            occurredAt: BusinessCalendar.utcFromGaborone(
              year: 2026,
              month: 9,
              day: 15,
            ),
          ),
          entry(
            id: 'oct-sale',
            type: MoneyMovementType.sale,
            amount: 90000,
            occurredAt: BusinessCalendar.utcFromGaborone(
              year: 2026,
              month: 10,
              day: 5,
            ),
          ),
          entry(
            id: 'oct-expense',
            type: MoneyMovementType.expense,
            amount: 10000,
            occurredAt: BusinessCalendar.utcFromGaborone(
              year: 2026,
              month: 10,
              day: 6,
            ),
          ),
        ],
        openingCashMinor: 200000,
        currencyCode: 'BWP',
        period: september,
        asOf: asOf,
      );

      expect(summary.recordedSalesMinor, 40000);
      expect(summary.recordedOperatingExpensesMinor, 0);
      expect(summary.currentCashMinor, 320000);
    },
  );

  test('product sales use the same cash and operating-result rules', () {
    final summary = FinancialEngine.summarize(
      entries: [
        entry(id: 'paid-goods', type: MoneyMovementType.sale, amount: 1250),
        entry(
          id: 'unpaid-goods',
          type: MoneyMovementType.sale,
          amount: 1250,
          status: PaymentStatus.unpaid,
        ),
      ],
      openingCashMinor: 200000,
      currencyCode: 'BWP',
      period: october,
      asOf: asOf,
    );

    expect(summary.recordedSalesMinor, 2500);
    expect(summary.unpaidSalesMinor, 1250);
    expect(summary.currentCashMinor, 201250);
    expect(summary.netRecordedOperatingResultMinor, 2500);
    expect(summary.recordedOperatingExpensesMinor, 0);
  });

  test('unpaid refunds reduce period sales but not cash', () {
    final summary = FinancialEngine.summarize(
      entries: [
        entry(id: 'sale', type: MoneyMovementType.sale, amount: 50000),
        entry(
          id: 'refund',
          type: MoneyMovementType.refund,
          amount: 20000,
          status: PaymentStatus.unpaid,
        ),
      ],
      openingCashMinor: 0,
      currencyCode: 'BWP',
      period: october,
      asOf: asOf,
    );

    expect(summary.recordedRefundsMinor, 20000);
    expect(summary.netRecordedSalesMinor, 30000);
    expect(summary.currentCashMinor, 50000);
  });
}
