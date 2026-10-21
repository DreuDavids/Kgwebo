enum MoneyMovementType {
  sale,
  expense,
  refund,
  ownerContribution,
  ownerWithdrawal,
}

enum PaymentStatus { paid, unpaid }

/// Confirmed financial event used by [FinancialEngine].
///
/// This is intentionally independent of Flutter, Drift and Supabase.
class LedgerEntry {
  const LedgerEntry({
    required this.id,
    required this.type,
    required this.amountMinor,
    required this.currencyCode,
    required this.occurredAt,
    required this.paymentStatus,
  });

  final String id;
  final MoneyMovementType type;
  final int amountMinor;
  final String currencyCode;
  final DateTime occurredAt;
  final PaymentStatus paymentStatus;
}
