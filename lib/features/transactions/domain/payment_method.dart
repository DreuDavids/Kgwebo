enum PaymentMethod { cash, mobileMoney, bankTransfer, other }

extension PaymentMethodCodec on PaymentMethod {
  String get storageValue {
    return switch (this) {
      PaymentMethod.cash => 'cash',
      PaymentMethod.mobileMoney => 'mobile_money',
      PaymentMethod.bankTransfer => 'bank_transfer',
      PaymentMethod.other => 'other',
    };
  }

  String get label {
    return switch (this) {
      PaymentMethod.cash => 'Cash',
      PaymentMethod.mobileMoney => 'Mobile money',
      PaymentMethod.bankTransfer => 'Bank transfer',
      PaymentMethod.other => 'Other',
    };
  }

  static PaymentMethod fromStorage(String raw) {
    return switch (raw) {
      'cash' => PaymentMethod.cash,
      'mobile_money' => PaymentMethod.mobileMoney,
      'bank_transfer' => PaymentMethod.bankTransfer,
      'other' => PaymentMethod.other,
      _ => throw FormatException('Unknown payment method', raw),
    };
  }
}
