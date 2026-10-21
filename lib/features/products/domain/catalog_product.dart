import '../../../core/inventory/stock_status.dart';
import '../../../core/inventory/unit_of_measure.dart';

class CatalogProduct {
  const CatalogProduct({
    required this.id,
    required this.businessId,
    required this.ownerId,
    required this.createdBy,
    required this.name,
    required this.sellingPriceMinor,
    required this.stockQuantityMilli,
    required this.unitOfMeasure,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.sku,
    this.description,
    this.unitCostMinor,
    this.lowStockThresholdMilli,
  });

  final String id;
  final String businessId;
  final String ownerId;
  final String createdBy;
  final String name;
  final String? sku;
  final String? description;
  final int sellingPriceMinor;
  final int? unitCostMinor;
  final int stockQuantityMilli;
  final int? lowStockThresholdMilli;
  final UnitOfMeasure unitOfMeasure;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool belongsTo({required String ownerId, required String businessId}) {
    return this.ownerId == ownerId && this.businessId == businessId;
  }

  StockAvailability get availability {
    return stockAvailability(
      quantityMilli: stockQuantityMilli,
      lowStockThresholdMilli: lowStockThresholdMilli,
    );
  }

  bool get hasRecordedCost => unitCostMinor != null;

  factory CatalogProduct.fromMap(
    Map<String, dynamic> row, {
    required String ownerId,
  }) {
    return CatalogProduct(
      id: row['id'] as String,
      businessId: row['business_id'] as String,
      ownerId: ownerId,
      createdBy: row['created_by'] as String,
      name: row['name'] as String,
      sku: row['sku'] as String?,
      description: row['description'] as String?,
      sellingPriceMinor: (row['selling_price_minor'] as num).toInt(),
      unitCostMinor: (row['unit_cost_minor'] as num?)?.toInt(),
      stockQuantityMilli: (row['stock_quantity_milli'] as num).toInt(),
      lowStockThresholdMilli:
          (row['low_stock_threshold_milli'] as num?)?.toInt(),
      unitOfMeasure: UnitOfMeasureX.fromStorage(
        row['unit_of_measure'] as String,
      ),
      isActive: row['is_active'] as bool,
      createdAt: _stamp(row['created_at']),
      updatedAt: _stamp(row['updated_at']),
    );
  }

  static DateTime _stamp(Object raw) {
    if (raw is DateTime) {
      return raw.toUtc();
    }
    return DateTime.parse(raw.toString()).toUtc();
  }
}
