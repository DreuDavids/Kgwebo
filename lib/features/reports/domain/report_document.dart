import '../../../core/finance/business_calendar.dart';

/// Immutable report values produced from [FinancialEngine] output.
///
/// Widgets and PDF generators must render these fields. They must not
/// recalculate cash, sales, expenses or operating results.
class ReportDocument {
  const ReportDocument({
    required this.businessName,
    required this.businessType,
    required this.countryLabel,
    required this.currencyCode,
    required this.periodLabel,
    required this.period,
    required this.zoneName,
    required this.generatedAt,
    required this.recordedSalesMinor,
    required this.recordedRefundsMinor,
    required this.netRecordedSalesMinor,
    required this.recordedOperatingExpensesMinor,
    required this.netRecordedOperatingResultMinor,
    required this.currentRecordedCashMinor,
    required this.unpaidSalesMinor,
    required this.unpaidExpensesMinor,
    required this.saleCount,
    required this.refundCount,
    required this.expenseCount,
    required this.contributionCount,
    required this.withdrawalCount,
    required this.confirmedInPeriodCount,
    required this.skippedMixedCurrency,
    required this.historyIncomplete,
    required this.isStale,
    required this.notes,
    required this.disclaimer,
    this.description,
    this.periodOpeningCashMinor,
    this.periodClosingCashMinor,
    this.contactPhone,
    this.ownerId,
  });

  final String businessName;
  final String businessType;
  final String countryLabel;
  final String? description;
  final String currencyCode;
  final String periodLabel;
  final ReportingPeriod period;
  final String zoneName;
  final DateTime generatedAt;
  final int recordedSalesMinor;
  final int recordedRefundsMinor;
  final int netRecordedSalesMinor;
  final int recordedOperatingExpensesMinor;
  final int netRecordedOperatingResultMinor;
  final int currentRecordedCashMinor;
  final int unpaidSalesMinor;
  final int unpaidExpensesMinor;
  final int saleCount;
  final int refundCount;
  final int expenseCount;
  final int contributionCount;
  final int withdrawalCount;
  final int confirmedInPeriodCount;
  final int skippedMixedCurrency;
  final bool historyIncomplete;
  final bool isStale;
  final List<String> notes;
  final String disclaimer;
  final int? periodOpeningCashMinor;
  final int? periodClosingCashMinor;

  /// Always null. The field exists so tests can prove private data is omitted.
  final String? contactPhone;

  /// Always null. The field exists so tests can prove private data is omitted.
  final String? ownerId;

  bool get isEmptyPeriod => confirmedInPeriodCount == 0;

  bool get hasPeriodCash =>
      periodOpeningCashMinor != null && periodClosingCashMinor != null;
}
