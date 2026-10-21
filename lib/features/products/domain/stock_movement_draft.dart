import 'stock_movement_type.dart';

class StockMovementDraft {
  const StockMovementDraft({
    required this.type,
    required this.quantityText,
    this.idempotencyKey = '',
    this.unitCostText = '',
    this.reason = '',
    this.notes = '',
    this.reference = '',
    this.reversesMovementId,
  });

  final StockMovementType type;
  final String quantityText;
  final String unitCostText;
  final String reason;
  final String notes;
  final String reference;
  final String idempotencyKey;
  final String? reversesMovementId;
}
