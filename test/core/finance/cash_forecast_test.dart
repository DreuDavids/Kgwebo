import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/business_calendar.dart';
import 'package:kgwebo/core/finance/cash_forecast.dart';
import 'package:kgwebo/core/finance/cash_outlook.dart';
import 'package:kgwebo/core/finance/financial_engine.dart';
import 'package:kgwebo/core/finance/ledger_entry.dart';

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

  CashForecast forecast({
    int cash = 255000,
    ForecastHorizon horizon = ForecastHorizon.days7,
    Iterable<ScheduledCommitment> commitments = const [],
    int unpaidSalesMinor = 0,
    int unpaidExpensesMinor = 0,
    int inventoryValueMinor = 0,
    bool hitRecordCap = false,
    int skippedMixedCurrencyTransactions = 0,
  }) {
    return CashForecastEngine.project(
      currentCashMinor: cash,
      currencyCode: 'BWP',
      asOf: asOf,
      zone: zone,
      horizon: horizon,
      commitments: commitments,
      unpaidSalesMinor: unpaidSalesMinor,
      unpaidExpensesMinor: unpaidExpensesMinor,
      inventoryValueMinor: inventoryValueMinor,
      hitRecordCap: hitRecordCap,
      skippedMixedCurrencyTransactions: skippedMixedCurrencyTransactions,
    );
  }

  test('7-day window is inclusive of today and the sixth following day', () {
    final result = forecast(
      commitments: [
        bill(id: 'today', amount: 10000, dueOn: DateTime(2026, 10, 21)),
        bill(id: 'last-day', amount: 20000, dueOn: DateTime(2026, 10, 27)),
        bill(id: 'after', amount: 40000, dueOn: DateTime(2026, 10, 28)),
      ],
    );

    expect(result.asOfDate, DateTime(2026, 10, 21));
    expect(result.horizonEndDate, DateTime(2026, 10, 27));
    expect(result.daily, hasLength(7));
    expect(result.daily.first.wallDate, DateTime(2026, 10, 21));
    expect(result.daily.last.wallDate, DateTime(2026, 10, 27));
    expect(result.upcomingWithinHorizonMinor, 30000);
    expect(result.upcomingAfterHorizonMinor, 40000);
    expect(result.estimatedCashAfterKnownCommitmentsMinor, 225000);
    expect(result.currentCashMinor, 255000);
  });

  test('14 and 30 day windows use local calendar boundaries', () {
    final fourteen = forecast(
      horizon: ForecastHorizon.days14,
      commitments: [
        bill(id: 'day14', amount: 10000, dueOn: DateTime(2026, 11, 3)),
        bill(id: 'day15', amount: 20000, dueOn: DateTime(2026, 11, 4)),
      ],
    );
    final thirty = forecast(
      horizon: ForecastHorizon.days30,
      commitments: [
        bill(id: 'day30', amount: 10000, dueOn: DateTime(2026, 11, 19)),
        bill(id: 'day31', amount: 20000, dueOn: DateTime(2026, 11, 20)),
      ],
    );

    expect(fourteen.horizonEndDate, DateTime(2026, 11, 3));
    expect(fourteen.upcomingWithinHorizonMinor, 10000);
    expect(fourteen.upcomingAfterHorizonMinor, 20000);
    expect(thirty.horizonEndDate, DateTime(2026, 11, 19));
    expect(thirty.upcomingWithinHorizonMinor, 10000);
    expect(thirty.upcomingAfterHorizonMinor, 20000);
  });

  test('recorded cash is unchanged by unpaid commitments', () {
    final result = forecast(
      cash: 255000,
      commitments: [
        bill(id: 'rent', amount: 80000, dueOn: DateTime(2026, 10, 24)),
      ],
    );

    expect(result.currentCashMinor, 255000);
    expect(result.estimatedCashAfterKnownCommitmentsMinor, 175000);
  });

  test('opening cash, paid movements and refunds feed recorded cash', () {
    final october = BusinessCalendar.gaboroneMonthContaining(asOf);
    final summary = FinancialEngine.summarize(
      entries: [
        LedgerEntry(
          id: 'sale',
          type: MoneyMovementType.sale,
          amountMinor: 50000,
          currencyCode: 'BWP',
          occurredAt: DateTime.utc(2026, 10, 10),
          paymentStatus: PaymentStatus.paid,
        ),
        LedgerEntry(
          id: 'expense',
          type: MoneyMovementType.expense,
          amountMinor: 10000,
          currencyCode: 'BWP',
          occurredAt: DateTime.utc(2026, 10, 11),
          paymentStatus: PaymentStatus.paid,
        ),
        LedgerEntry(
          id: 'in',
          type: MoneyMovementType.ownerContribution,
          amountMinor: 20000,
          currencyCode: 'BWP',
          occurredAt: DateTime.utc(2026, 10, 12),
          paymentStatus: PaymentStatus.paid,
        ),
        LedgerEntry(
          id: 'out',
          type: MoneyMovementType.ownerWithdrawal,
          amountMinor: 5000,
          currencyCode: 'BWP',
          occurredAt: DateTime.utc(2026, 10, 13),
          paymentStatus: PaymentStatus.paid,
        ),
        LedgerEntry(
          id: 'refund',
          type: MoneyMovementType.refund,
          amountMinor: 2000,
          currencyCode: 'BWP',
          occurredAt: DateTime.utc(2026, 10, 14),
          paymentStatus: PaymentStatus.paid,
        ),
      ],
      openingCashMinor: 200000,
      currencyCode: 'BWP',
      period: october,
      asOf: asOf,
    );

    final result = forecast(cash: summary.currentCashMinor);
    expect(summary.currentCashMinor, 253000);
    expect(result.currentCashMinor, 253000);
    expect(result.estimatedCashAfterKnownCommitmentsMinor, 253000);
  });

  test('unpaid sales are not treated as cash or expected receipts', () {
    final result = forecast(
      cash: 200000,
      unpaidSalesMinor: 50000,
      commitments: [
        bill(id: 'rent', amount: 30000, dueOn: DateTime(2026, 10, 25)),
      ],
    );

    expect(result.currentCashMinor, 200000);
    expect(result.expectedIncomingMinor, 0);
    expect(result.incomingForecastAvailable, isFalse);
    expect(result.estimatedCashAfterKnownCommitmentsMinor, 170000);
    expect(
      result.limitations.map((item) => item.code),
      contains(CashForecastEngine.incomingNotForecast),
    );
  });

  test('overdue bills are separate from upcoming bills in the window', () {
    final result = forecast(
      cash: 100000,
      commitments: [
        bill(id: 'late', amount: 30000, dueOn: DateTime(2026, 10, 1)),
        bill(id: 'soon', amount: 20000, dueOn: DateTime(2026, 10, 21)),
        bill(id: 'later', amount: 40000, dueOn: DateTime(2026, 11, 1)),
      ],
    );

    expect(result.overdueMinor, 30000);
    expect(result.upcomingWithinHorizonMinor, 20000);
    expect(result.upcomingAfterHorizonMinor, 40000);
    expect(result.estimatedCashAfterKnownCommitmentsMinor, 50000);
    expect(result.daily.first.outflowMinor, 50000);
    expect(result.daily.first.projectedCashMinor, 50000);
  });

  test('paid and cancelled commitments are excluded', () {
    final result = forecast(
      cash: 50000,
      commitments: [
        bill(
          id: 'paid',
          amount: 20000,
          dueOn: DateTime(2026, 10, 24),
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

    expect(result.upcomingWithinHorizonMinor, 10000);
    expect(result.overdueMinor, 0);
    expect(result.estimatedCashAfterKnownCommitmentsMinor, 40000);
  });

  test('paid expenses are not subtracted again as commitments', () {
    final october = BusinessCalendar.gaboroneMonthContaining(asOf);
    final summary = FinancialEngine.summarize(
      entries: [
        LedgerEntry(
          id: 'exp',
          type: MoneyMovementType.expense,
          amountMinor: 80000,
          currencyCode: 'BWP',
          occurredAt: DateTime.utc(2026, 10, 10),
          paymentStatus: PaymentStatus.paid,
        ),
      ],
      openingCashMinor: 200000,
      currencyCode: 'BWP',
      period: october,
      asOf: asOf,
    );
    final result = forecast(
      cash: summary.currentCashMinor,
      commitments: [
        bill(
          id: 'rent',
          amount: 80000,
          dueOn: DateTime(2026, 10, 24),
          status: CommitmentStatus.paid,
        ),
      ],
    );

    expect(summary.currentCashMinor, 120000);
    expect(result.estimatedCashAfterKnownCommitmentsMinor, 120000);
  });

  test('unpaid recorded expenses are not dated forecast outflows', () {
    final result = forecast(
      cash: 200000,
      unpaidExpensesMinor: 40000,
      commitments: [
        bill(id: 'rent', amount: 30000, dueOn: DateTime(2026, 10, 24)),
      ],
    );

    expect(result.estimatedCashAfterKnownCommitmentsMinor, 170000);
    expect(
      result.limitations.map((item) => item.code),
      contains(CashForecastEngine.unpaidExpensesNotDated),
    );
  });

  test('inventory value is never treated as cash', () {
    final result = forecast(
      cash: 200000,
      inventoryValueMinor: 150000,
      commitments: const [],
    );

    expect(result.currentCashMinor, 200000);
    expect(result.estimatedCashAfterKnownCommitmentsMinor, 200000);
    expect(
      result.limitations.map((item) => item.code),
      contains(CashForecastEngine.inventoryNotCash),
    );
  });

  test('duplicate ids and mixed currency rows are skipped', () {
    final rent = bill(id: 'rent', amount: 50000, dueOn: DateTime(2026, 10, 24));
    final result = forecast(
      cash: 80000,
      commitments: [
        rent,
        rent,
        bill(
          id: 'zar',
          amount: 20000,
          dueOn: DateTime(2026, 10, 24),
          currency: 'ZAR',
        ),
      ],
    );

    expect(result.upcomingWithinHorizonMinor, 50000);
    expect(result.skippedMixedCurrency, 1);
    expect(result.countedCommitments, 1);
  });

  test('daily path applies overdue on the first day then due dates', () {
    final result = forecast(
      cash: 100000,
      commitments: [
        bill(id: 'late', amount: 40000, dueOn: DateTime(2026, 10, 1)),
        bill(id: 'thu', amount: 20000, dueOn: DateTime(2026, 10, 22)),
      ],
    );

    expect(result.daily[0].projectedCashMinor, 60000);
    expect(result.daily[1].projectedCashMinor, 40000);
    expect(result.daily[1].outflowMinor, 20000);
    expect(result.daily[2].projectedCashMinor, 40000);
    expect(result.firstInsufficientOn, isNull);
  });

  test(
    'insufficient-cash date is the first day projected cash is negative',
    () {
      final result = forecast(
        cash: 30000,
        commitments: [
          bill(id: 'soon', amount: 20000, dueOn: DateTime(2026, 10, 22)),
          bill(id: 'later', amount: 20000, dueOn: DateTime(2026, 10, 24)),
        ],
      );

      expect(result.daily[0].projectedCashMinor, 30000);
      expect(result.daily[1].projectedCashMinor, 10000);
      expect(result.daily[3].projectedCashMinor, -10000);
      expect(result.firstInsufficientOn, DateTime(2026, 10, 24));
      expect(result.estimatedCashAfterKnownCommitmentsMinor, -10000);
    },
  );

  test('empty commitments leave recorded cash unchanged', () {
    final result = forecast(cash: 200000, commitments: const []);

    expect(result.upcomingWithinHorizonMinor, 0);
    expect(result.estimatedCashAfterKnownCommitmentsMinor, 200000);
    expect(result.hasKnownOutflows, isFalse);
    expect(result.hasProjectedPath, isFalse);
    expect(
      result.daily.every((day) => day.projectedCashMinor == 200000),
      isTrue,
    );
  });

  test('incomplete history is labelled rather than invented', () {
    final result = forecast(cash: 200000, hitRecordCap: true);

    expect(
      result.limitations.map((item) => item.code),
      contains(CashForecastEngine.incompleteHistory),
    );
    expect(result.currentCashMinor, 200000);
    expect(result.expectedIncomingMinor, 0);
  });

  test('assumptions explain that incoming cash is not forecast', () {
    final result = forecast();
    expect(
      result.assumptions.join(' ').toLowerCase(),
      contains('incoming cash is not forecast'),
    );
    expect(
      result.assumptions.join(' ').toLowerCase(),
      contains('not a guarantee'),
    );
  });
}
