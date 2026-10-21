import 'business_calendar.dart';

/// Totals produced by [FinancialEngine] from confirmed ledger entries.
class FinancialSummary {
  const FinancialSummary({
    required this.currencyCode,
    required this.period,
    required this.openingCashMinor,
    required this.recordedSalesMinor,
    required this.recordedRefundsMinor,
    required this.recordedOperatingExpensesMinor,
    required this.netRecordedSalesMinor,
    required this.netRecordedOperatingResultMinor,
    required this.currentCashMinor,
    required this.unpaidSalesMinor,
    required this.unpaidExpensesMinor,
    required this.countedEntries,
    required this.skippedMixedCurrency,
  });

  final String currencyCode;
  final ReportingPeriod period;
  final int openingCashMinor;
  final int recordedSalesMinor;
  final int recordedRefundsMinor;
  final int recordedOperatingExpensesMinor;
  final int netRecordedSalesMinor;
  final int netRecordedOperatingResultMinor;
  final int currentCashMinor;
  final int unpaidSalesMinor;
  final int unpaidExpensesMinor;
  final int countedEntries;
  final int skippedMixedCurrency;
}
