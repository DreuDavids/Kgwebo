/// Read-only figures from trusted Kgwebo services. The model must not invent them.
class VerifiedFinancialSnapshot {
  const VerifiedFinancialSnapshot({
    required this.currencyCode,
    required this.recordedCashMinor,
    required this.recordedSalesMinor,
    required this.recordedExpensesMinor,
    required this.netOperatingResultMinor,
    required this.periodLabel,
    required this.source,
  });

  final String currencyCode;
  final int recordedCashMinor;
  final int recordedSalesMinor;
  final int recordedExpensesMinor;
  final int netOperatingResultMinor;
  final String periodLabel;
  final String source;
}

abstract class FinancialReadPort {
  Future<VerifiedFinancialSnapshot?> currentSnapshot();
}
