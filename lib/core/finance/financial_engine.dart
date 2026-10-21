import '../money/money_limits.dart';
import 'business_calendar.dart';
import 'finance_exception.dart';
import 'financial_summary.dart';
import 'ledger_entry.dart';

/// Pure financial calculations. Independent of widgets and I/O.
abstract final class FinancialEngine {
  static FinancialSummary summarize({
    required Iterable<LedgerEntry> entries,
    required int openingCashMinor,
    required String currencyCode,
    required ReportingPeriod period,
    required DateTime asOf,
  }) {
    if (openingCashMinor < 0) {
      throw const FinanceException('Opening cash cannot be negative.');
    }
    if (currencyCode.trim().length != 3) {
      throw const FinanceException('A three-letter currency code is required.');
    }

    final seenIds = <String>{};
    var recordedSales = 0;
    var recordedRefunds = 0;
    var recordedExpenses = 0;
    var cash = openingCashMinor;
    var unpaidSales = 0;
    var unpaidExpenses = 0;
    var counted = 0;
    var skippedMixed = 0;

    for (final entry in entries) {
      if (entry.id.isEmpty) {
        throw const FinanceException('Every ledger entry needs a stable id.');
      }
      if (!seenIds.add(entry.id)) {
        continue;
      }
      if (entry.currencyCode != currencyCode) {
        skippedMixed += 1;
        continue;
      }
      _validateAmount(entry.amountMinor);

      final inPeriod = period.contains(entry.occurredAt);
      final paid = entry.paymentStatus == PaymentStatus.paid;
      final occurredByAsOf = !entry.occurredAt.toUtc().isAfter(asOf.toUtc());

      switch (entry.type) {
        case MoneyMovementType.sale:
          if (inPeriod) {
            recordedSales = _add(recordedSales, entry.amountMinor);
            if (!paid) {
              unpaidSales = _add(unpaidSales, entry.amountMinor);
            }
          }
          if (paid && occurredByAsOf) {
            cash = _add(cash, entry.amountMinor);
          }
        case MoneyMovementType.expense:
          if (inPeriod) {
            recordedExpenses = _add(recordedExpenses, entry.amountMinor);
            if (!paid) {
              unpaidExpenses = _add(unpaidExpenses, entry.amountMinor);
            }
          }
          if (paid && occurredByAsOf) {
            cash = _add(cash, -entry.amountMinor);
          }
        case MoneyMovementType.refund:
          if (inPeriod) {
            recordedRefunds = _add(recordedRefunds, entry.amountMinor);
          }
          if (paid && occurredByAsOf) {
            cash = _add(cash, -entry.amountMinor);
          }
        case MoneyMovementType.ownerContribution:
          if (paid && occurredByAsOf) {
            cash = _add(cash, entry.amountMinor);
          }
        case MoneyMovementType.ownerWithdrawal:
          if (paid && occurredByAsOf) {
            cash = _add(cash, -entry.amountMinor);
          }
      }
      counted += 1;
    }

    final netSales = _add(recordedSales, -recordedRefunds);
    final netOperating = _add(netSales, -recordedExpenses);

    return FinancialSummary(
      currencyCode: currencyCode,
      period: period,
      openingCashMinor: openingCashMinor,
      recordedSalesMinor: recordedSales,
      recordedRefundsMinor: recordedRefunds,
      recordedOperatingExpensesMinor: recordedExpenses,
      netRecordedSalesMinor: netSales,
      netRecordedOperatingResultMinor: netOperating,
      currentCashMinor: cash,
      unpaidSalesMinor: unpaidSales,
      unpaidExpensesMinor: unpaidExpenses,
      countedEntries: counted,
      skippedMixedCurrency: skippedMixed,
    );
  }

  static void _validateAmount(int amountMinor) {
    if (amountMinor < MoneyLimits.minPositiveMinorUnits ||
        amountMinor > MoneyLimits.maxMinorUnits) {
      throw const FinanceException(
        'A transaction amount must be a positive amount within the supported range.',
      );
    }
  }

  static int _add(int left, int right) {
    if (right > 0 && left > MoneyLimits.maxSignedTotal - right) {
      throw const FinanceException(
        'A financial total exceeded the supported range.',
      );
    }
    if (right < 0 && left < MoneyLimits.minSignedTotal - right) {
      throw const FinanceException(
        'A financial total exceeded the supported range.',
      );
    }
    return left + right;
  }
}
