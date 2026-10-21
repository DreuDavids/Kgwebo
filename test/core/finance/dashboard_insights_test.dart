import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/business_calendar.dart';
import 'package:kgwebo/core/finance/cash_outlook.dart';
import 'package:kgwebo/core/finance/dashboard_insights.dart';
import 'package:kgwebo/core/finance/financial_engine.dart';
import 'package:kgwebo/core/finance/ledger_entry.dart';

void main() {
  final october = BusinessCalendar.gaboroneMonthContaining(
    DateTime.utc(2026, 10, 21),
  );
  final asOf = DateTime.utc(2026, 10, 21, 12);

  test('empty businesses do not get a false loss warning', () {
    final summary = FinancialEngine.summarize(
      entries: const [],
      openingCashMinor: 200000,
      currencyCode: 'BWP',
      period: october,
      asOf: asOf,
    );
    final outlook = CashOutlookEngine.summarize(
      currentCashMinor: summary.currentCashMinor,
      currencyCode: 'BWP',
      asOf: asOf,
      commitments: const [],
    );

    final insights = DashboardInsights.from(
      summary: summary,
      outlook: outlook,
      hitRecordCap: false,
    );

    expect(insights, isEmpty);
  });

  test('expenses exceeding sales produce an evidence-backed insight', () {
    final summary = FinancialEngine.summarize(
      entries: [
        LedgerEntry(
          id: 'sale',
          type: MoneyMovementType.sale,
          amountMinor: 10000,
          currencyCode: 'BWP',
          occurredAt: DateTime.utc(2026, 10, 10),
          paymentStatus: PaymentStatus.paid,
        ),
        LedgerEntry(
          id: 'exp',
          type: MoneyMovementType.expense,
          amountMinor: 40000,
          currencyCode: 'BWP',
          occurredAt: DateTime.utc(2026, 10, 11),
          paymentStatus: PaymentStatus.paid,
        ),
      ],
      openingCashMinor: 0,
      currencyCode: 'BWP',
      period: october,
      asOf: asOf,
    );
    final outlook = CashOutlookEngine.summarize(
      currentCashMinor: summary.currentCashMinor,
      currencyCode: 'BWP',
      asOf: asOf,
      commitments: const [],
    );

    final insights = DashboardInsights.from(
      summary: summary,
      outlook: outlook,
      hitRecordCap: false,
    );

    expect(
      insights.map((item) => item.kind),
      contains(DashboardInsightKind.expensesExceedSales),
    );
    expect(
      insights
          .singleWhere(
            (item) => item.kind == DashboardInsightKind.expensesExceedSales,
          )
          .evidence,
      contains('P 100.00'),
    );
  });

  test('overdue commitments are called out without calling them expenses', () {
    final summary = FinancialEngine.summarize(
      entries: const [],
      openingCashMinor: 50000,
      currencyCode: 'BWP',
      period: october,
      asOf: asOf,
    );
    final outlook = CashOutlookEngine.summarize(
      currentCashMinor: summary.currentCashMinor,
      currencyCode: 'BWP',
      asOf: asOf,
      commitments: [
        ScheduledCommitment(
          id: 'rent',
          amountMinor: 20000,
          currencyCode: 'BWP',
          dueOn: DateTime(2026, 10, 1),
          status: CommitmentStatus.unpaid,
        ),
      ],
    );

    final insights = DashboardInsights.from(
      summary: summary,
      outlook: outlook,
      hitRecordCap: false,
    );

    final overdue = insights.singleWhere(
      (item) => item.kind == DashboardInsightKind.overdueCommitments,
    );
    expect(
      overdue.evidence.toLowerCase(),
      isNot(contains('operating expense')),
    );
    expect(overdue.title.toLowerCase(), contains('overdue'));
  });

  test('capped history is not presented as complete', () {
    final summary = FinancialEngine.summarize(
      entries: const [],
      openingCashMinor: 0,
      currencyCode: 'BWP',
      period: october,
      asOf: asOf,
    );
    final outlook = CashOutlookEngine.summarize(
      currentCashMinor: 0,
      currencyCode: 'BWP',
      asOf: asOf,
      commitments: const [],
    );

    final insights = DashboardInsights.from(
      summary: summary,
      outlook: outlook,
      hitRecordCap: true,
    );

    expect(
      insights.map((item) => item.kind),
      contains(DashboardInsightKind.incompleteHistory),
    );
  });
}
