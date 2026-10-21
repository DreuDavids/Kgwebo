enum StockMovementType {
  opening,
  received,
  sold,
  customerReturn,
  returnDamaged,
  damaged,
  adjustmentIncrease,
  adjustmentDecrease,
  reversal;

  String get storageValue {
    return switch (this) {
      opening => 'opening',
      received => 'received',
      sold => 'sold',
      customerReturn => 'customer_return',
      returnDamaged => 'return_damaged',
      damaged => 'damaged',
      adjustmentIncrease => 'adjustment_increase',
      adjustmentDecrease => 'adjustment_decrease',
      reversal => 'reversal',
    };
  }

  String get label {
    return switch (this) {
      opening => 'Opening stock',
      received => 'Stock received',
      sold => 'Sold',
      customerReturn => 'Customer return',
      returnDamaged => 'Damaged return',
      damaged => 'Damaged or lost',
      adjustmentIncrease => 'Manual increase',
      adjustmentDecrease => 'Manual decrease',
      reversal => 'Reversal',
    };
  }

  /// Effect on available stock: +1 increase, -1 decrease, 0 no change.
  /// Reversal uses the opposite of the reversed movement, not this sign.
  int get quantityDeltaSign {
    return switch (this) {
      opening || received || customerReturn || adjustmentIncrease => 1,
      sold || damaged || adjustmentDecrease => -1,
      returnDamaged || reversal => 0,
    };
  }

  bool get requiresReason {
    return switch (this) {
      damaged ||
      returnDamaged ||
      adjustmentIncrease ||
      adjustmentDecrease => true,
      opening || received || sold || customerReturn || reversal => false,
    };
  }

  bool get recordsIncomingCost {
    return switch (this) {
      opening || received => true,
      sold ||
      customerReturn ||
      returnDamaged ||
      damaged ||
      adjustmentIncrease ||
      adjustmentDecrease ||
      reversal => false,
    };
  }

  static StockMovementType fromStorage(String raw) {
    return switch (raw) {
      'opening' => opening,
      'received' => received,
      'sold' => sold,
      'customer_return' => customerReturn,
      'return_damaged' => returnDamaged,
      'damaged' => damaged,
      'adjustment_increase' => adjustmentIncrease,
      'adjustment_decrease' => adjustmentDecrease,
      'reversal' => reversal,
      _ => throw FormatException('Unknown stock movement type', raw),
    };
  }
}
