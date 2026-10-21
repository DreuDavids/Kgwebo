import 'stock_movement_type.dart';

class StockMovement {
  const StockMovement({
    required this.id,
    required this.businessId,
    required this.productId,
    required this.ownerId,
    required this.createdBy,
    required this.idempotencyKey,
    required this.type,
    required this.quantityMilli,
    required this.quantityDeltaMilli,
    required this.resultingQuantityMilli,
    required this.createdAt,
    this.unitCostMinor,
    this.reason,
    this.notes,
    this.reference,
    this.transactionId,
    this.reversesMovementId,
  });

  final String id;
  final String businessId;
  final String productId;
  final String ownerId;
  final String createdBy;
  final String idempotencyKey;
  final StockMovementType type;
  final int quantityMilli;
  final int quantityDeltaMilli;
  final int resultingQuantityMilli;
  final int? unitCostMinor;
  final String? reason;
  final String? notes;
  final String? reference;
  final String? transactionId;
  final String? reversesMovementId;
  final DateTime createdAt;

  bool belongsTo({required String ownerId, required String businessId}) {
    return this.ownerId == ownerId && this.businessId == businessId;
  }

  factory StockMovement.fromMap(
    Map<String, dynamic> row, {
    required String ownerId,
  }) {
    return StockMovement(
      id: row['id'] as String,
      businessId: row['business_id'] as String,
      productId: row['product_id'] as String,
      ownerId: ownerId,
      createdBy: row['created_by'] as String,
      idempotencyKey: row['idempotency_key'] as String,
      type: StockMovementType.fromStorage(row['movement_type'] as String),
      quantityMilli: (row['quantity_milli'] as num).toInt(),
      quantityDeltaMilli: (row['quantity_delta_milli'] as num).toInt(),
      resultingQuantityMilli: (row['resulting_quantity_milli'] as num).toInt(),
      unitCostMinor: (row['unit_cost_minor'] as num?)?.toInt(),
      reason: row['reason'] as String?,
      notes: row['notes'] as String?,
      reference: row['reference'] as String?,
      transactionId: row['transaction_id'] as String?,
      reversesMovementId: row['reverses_movement_id'] as String?,
      createdAt: _stamp(row['created_at']),
    );
  }

  static DateTime _stamp(Object raw) {
    if (raw is DateTime) {
      return raw.toUtc();
    }
    return DateTime.parse(raw.toString()).toUtc();
  }
}
