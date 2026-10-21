/// Range guards for persisted minor-unit amounts and accumulated totals.
abstract final class MoneyLimits {
  /// Smallest positive amount that may be saved as a sale or expense.
  static const minPositiveMinorUnits = 1;

  /// Largest single transaction: 999,999,999,999.99 in a 2-decimal currency.
  static const maxMinorUnits = 99999999999999;

  /// Signed 64-bit range used for accumulated totals and PostgreSQL bigint.
  static const minSignedTotal = -9223372036854775808;
  static const maxSignedTotal = 9223372036854775807;
}
