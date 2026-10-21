import '../money/money_limits.dart';
import 'quantity.dart';

class InsufficientStockException implements Exception {
  const InsufficientStockException([
    this.message = 'There is not enough stock for this movement.',
  ]);

  final String message;

  @override
  String toString() => message;
}

/// Weighted-average cost on the product card; historical sales freeze the
/// unit cost that was current at the time of the sale.
abstract final class InventoryCosting {
  static int weightedAverageUnitCostMinor({
    required int currentQuantityMilli,
    required int? currentUnitCostMinor,
    required int incomingQuantityMilli,
    required int incomingUnitCostMinor,
  }) {
    if (incomingQuantityMilli <= 0) {
      throw ArgumentError.value(
        incomingQuantityMilli,
        'incomingQuantityMilli',
        'Incoming quantity must be positive.',
      );
    }
    if (incomingUnitCostMinor < 0) {
      throw ArgumentError.value(
        incomingUnitCostMinor,
        'incomingUnitCostMinor',
        'Cost cannot be negative.',
      );
    }
    if (currentQuantityMilli <= 0 || currentUnitCostMinor == null) {
      return incomingUnitCostMinor;
    }
    final totalMilli = currentQuantityMilli + incomingQuantityMilli;
    final numerator =
        BigInt.from(currentQuantityMilli) * BigInt.from(currentUnitCostMinor) +
        BigInt.from(incomingQuantityMilli) * BigInt.from(incomingUnitCostMinor);
    return (numerator ~/ BigInt.from(totalMilli)).toInt();
  }

  static int? estimatedValueMinor({
    required int quantityMilli,
    required int? unitCostMinor,
  }) {
    if (unitCostMinor == null) {
      return null;
    }
    return _scale(quantityMilli, unitCostMinor);
  }

  static int lineTotalMinor({
    required int quantityMilli,
    required int unitPriceMinor,
  }) {
    final total = _scale(quantityMilli, unitPriceMinor);
    if (total < MoneyLimits.minPositiveMinorUnits) {
      throw ArgumentError(
        'A sale line must total at least 0.01 in the business currency.',
      );
    }
    return total;
  }

  static int? lineCogsMinor({
    required int quantityMilli,
    required int? unitCostMinor,
  }) {
    if (unitCostMinor == null) {
      return null;
    }
    return _scale(quantityMilli, unitCostMinor);
  }

  static int applyStockDelta({
    required int currentQuantityMilli,
    required int deltaMilli,
  }) {
    final next = currentQuantityMilli + deltaMilli;
    if (next < 0) {
      throw const InsufficientStockException();
    }
    if (next > Quantity.maxMilli) {
      throw ArgumentError('Stock quantity is too large to store.');
    }
    return next;
  }

  static int _scale(int quantityMilli, int unitMinor) {
    return (BigInt.from(quantityMilli) *
            BigInt.from(unitMinor) ~/
            BigInt.from(Quantity.milliScale))
        .toInt();
  }
}
