import '../../../core/finance/business_calendar.dart';
import '../../../core/finance/financial_engine.dart';
import '../../../core/finance/ledger_entry.dart';
import '../../onboarding/domain/business_profile.dart';
import '../../onboarding/domain/onboarding_options.dart';
import '../domain/report_document.dart';

/// Builds a [ReportDocument] from confirmed ledger entries and the engine.
abstract final class ReportBuilder {
  static const disclaimer =
      'This is a cash-basis summary of records saved in Kgwebo. '
      'It is not audited accounts, tax profit, or a formal financial statement. '
      'Opening cash is a starting position, not revenue. Unpaid sales are not '
      'cash received. Owner contributions and withdrawals are not operating '
      'sales or expenses. Unpaid bills do not reduce recorded cash. Pending '
      'pending changes are not included.';

  static ReportDocument build({
    required BusinessProfile business,
    required Iterable<LedgerEntry> entries,
    required ReportingPeriod period,
    required String periodLabel,
    required DateTime generatedAt,
    required bool isStale,
    required bool historyIncomplete,
  }) {
    final currencyCode = business.currencyCode;
    final zone = BusinessZone.forCountry(business.countryCode);
    final asOf = generatedAt.toUtc();
    final confirmed = List<LedgerEntry>.from(entries);
    final summary = FinancialEngine.summarize(
      entries: confirmed,
      openingCashMinor: business.openingBalanceMinor,
      currencyCode: currencyCode,
      period: period,
      asOf: asOf,
    );

    var saleCount = 0;
    var refundCount = 0;
    var expenseCount = 0;
    var contributionCount = 0;
    var withdrawalCount = 0;
    var confirmedInPeriodCount = 0;
    for (final entry in confirmed) {
      if (entry.currencyCode != currencyCode) {
        continue;
      }
      if (!period.contains(entry.occurredAt)) {
        continue;
      }
      confirmedInPeriodCount += 1;
      switch (entry.type) {
        case MoneyMovementType.sale:
          saleCount += 1;
        case MoneyMovementType.expense:
          expenseCount += 1;
        case MoneyMovementType.refund:
          refundCount += 1;
        case MoneyMovementType.ownerContribution:
          contributionCount += 1;
        case MoneyMovementType.ownerWithdrawal:
          withdrawalCount += 1;
      }
    }

    int? periodOpeningCashMinor;
    int? periodClosingCashMinor;
    if (!historyIncomplete) {
      final openingAsOf = period.startInclusive.toUtc().subtract(
        const Duration(microseconds: 1),
      );
      periodOpeningCashMinor =
          FinancialEngine.summarize(
            entries: confirmed,
            openingCashMinor: business.openingBalanceMinor,
            currencyCode: currencyCode,
            period: period,
            asOf: openingAsOf,
          ).currentCashMinor;
      final periodEndAsOf = period.endExclusive.toUtc().subtract(
        const Duration(microseconds: 1),
      );
      final closingAsOf = asOf.isBefore(periodEndAsOf) ? asOf : periodEndAsOf;
      periodClosingCashMinor =
          FinancialEngine.summarize(
            entries: confirmed,
            openingCashMinor: business.openingBalanceMinor,
            currencyCode: currencyCode,
            period: period,
            asOf: closingAsOf,
          ).currentCashMinor;
    }

    return ReportDocument(
      businessName: business.name.trim(),
      businessType: business.businessType.trim(),
      countryLabel: OnboardingOptions.countryLabel(business.countryCode),
      description: _optionalText(business.description),
      currencyCode: currencyCode,
      periodLabel: periodLabel,
      period: period,
      zoneName: zone.name,
      generatedAt: asOf,
      recordedSalesMinor: summary.recordedSalesMinor,
      recordedRefundsMinor: summary.recordedRefundsMinor,
      netRecordedSalesMinor: summary.netRecordedSalesMinor,
      recordedOperatingExpensesMinor: summary.recordedOperatingExpensesMinor,
      netRecordedOperatingResultMinor: summary.netRecordedOperatingResultMinor,
      currentRecordedCashMinor: summary.currentCashMinor,
      unpaidSalesMinor: summary.unpaidSalesMinor,
      unpaidExpensesMinor: summary.unpaidExpensesMinor,
      saleCount: saleCount,
      refundCount: refundCount,
      expenseCount: expenseCount,
      contributionCount: contributionCount,
      withdrawalCount: withdrawalCount,
      confirmedInPeriodCount: confirmedInPeriodCount,
      skippedMixedCurrency: summary.skippedMixedCurrency,
      historyIncomplete: historyIncomplete,
      isStale: isStale,
      periodOpeningCashMinor: periodOpeningCashMinor,
      periodClosingCashMinor: periodClosingCashMinor,
      notes: _notes(
        isStale: isStale,
        historyIncomplete: historyIncomplete,
        unpaidSalesMinor: summary.unpaidSalesMinor,
        unpaidExpensesMinor: summary.unpaidExpensesMinor,
        contributionCount: contributionCount,
        withdrawalCount: withdrawalCount,
        skippedMixedCurrency: summary.skippedMixedCurrency,
        isEmptyPeriod: confirmedInPeriodCount == 0,
      ),
      disclaimer: disclaimer,
    );
  }

  static String? _optionalText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  static List<String> _notes({
    required bool isStale,
    required bool historyIncomplete,
    required int unpaidSalesMinor,
    required int unpaidExpensesMinor,
    required int contributionCount,
    required int withdrawalCount,
    required int skippedMixedCurrency,
    required bool isEmptyPeriod,
  }) {
    return [
      if (isStale)
        'Showing saved figures from this device. They may not include the latest server copy.',
      if (historyIncomplete)
        'Not all history could be loaded, so period opening cash is omitted. It cannot be established accurately from a partial ledger.',
      if (isEmptyPeriod)
        'No confirmed transactions were recorded in this period. Opening cash is a starting balance, not a sale.',
      if (unpaidSalesMinor > 0)
        'Unpaid sales are included in recorded sales. They are not cash received.',
      if (unpaidExpensesMinor > 0)
        'Unpaid operating expenses are included in the operating result. They have not reduced recorded cash.',
      if (contributionCount > 0 || withdrawalCount > 0)
        'Owner contributions and withdrawals move recorded cash. They are not operating sales or expenses.',
      if (skippedMixedCurrency > 0)
        '$skippedMixedCurrency transaction${skippedMixedCurrency == 1 ? '' : 's'} in another currency ${skippedMixedCurrency == 1 ? 'was' : 'were'} skipped and not converted.',
    ];
  }
}
