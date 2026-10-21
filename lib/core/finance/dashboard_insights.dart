import '../money/money_formatter.dart';
import 'cash_outlook.dart';
import 'financial_summary.dart';

enum DashboardInsightKind {
  emptyPeriod,
  expensesExceedSales,
  overdueCommitments,
  incompleteHistory,
  mixedCurrency,
}

class DashboardInsight {
  const DashboardInsight({
    required this.kind,
    required this.title,
    required this.evidence,
  });

  final DashboardInsightKind kind;
  final String title;
  final String evidence;
}

/// Deterministic dashboard notices. Not a persisted recommendation engine.
abstract final class DashboardInsights {
  static List<DashboardInsight> from({
    required FinancialSummary summary,
    required CashOutlook? outlook,
    required bool hitRecordCap,
  }) {
    final insights = <DashboardInsight>[];
    final currency = summary.currencyCode;

    if (hitRecordCap) {
      insights.add(
        const DashboardInsight(
          kind: DashboardInsightKind.incompleteHistory,
          title: 'This summary is incomplete',
          evidence:
              'Totals use the most recent 5,000 confirmed transactions. Older rows are not included, so cash and period figures may understate the full history.',
        ),
      );
    }

    if (summary.skippedMixedCurrency > 0) {
      insights.add(
        DashboardInsight(
          kind: DashboardInsightKind.mixedCurrency,
          title: 'Some rows were excluded',
          evidence:
              '${summary.skippedMixedCurrency} confirmed rows in another currency were left out of these $currency totals. Mixed-currency conversion is not supported.',
        ),
      );
    }

    final hasPeriodActivity =
        summary.recordedSalesMinor != 0 ||
        summary.recordedOperatingExpensesMinor != 0 ||
        summary.recordedRefundsMinor != 0;

    if (summary.countedEntries > 0 && !hasPeriodActivity) {
      insights.add(
        const DashboardInsight(
          kind: DashboardInsightKind.emptyPeriod,
          title: 'No recorded activity in this period',
          evidence:
              'Cash still includes opening cash and paid movements from other dates. This is not a zero-profit result.',
        ),
      );
    }

    if (hasPeriodActivity && summary.netRecordedOperatingResultMinor < 0) {
      insights.add(
        DashboardInsight(
          kind: DashboardInsightKind.expensesExceedSales,
          title: 'Recorded expenses exceeded recorded sales',
          evidence:
              'Recorded sales ${MoneyFormatter.formatMinor(summary.recordedSalesMinor, currencyCode: currency)} minus refunds ${MoneyFormatter.formatMinor(summary.recordedRefundsMinor, currencyCode: currency)} and operating expenses ${MoneyFormatter.formatMinor(summary.recordedOperatingExpensesMinor, currencyCode: currency)} left a net recorded operating result of ${MoneyFormatter.formatMinor(summary.netRecordedOperatingResultMinor, currencyCode: currency)}. This is not cash on hand and not audited profit.',
        ),
      );
    }

    if (outlook != null && outlook.overdueMinor > 0) {
      insights.add(
        DashboardInsight(
          kind: DashboardInsightKind.overdueCommitments,
          title: 'Overdue commitments need attention',
          evidence:
              '${MoneyFormatter.formatMinor(outlook.overdueMinor, currencyCode: currency)} in unpaid commitments is past due. These bills are not yet recorded operating costs and have not reduced current recorded cash.',
        ),
      );
    }

    return insights;
  }
}
