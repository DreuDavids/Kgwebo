class SaleLine {
  const SaleLine({
    required this.id,
    required this.businessId,
    required this.transactionId,
    required this.productId,
    required this.quantityMilli,
    required this.unitPriceMinor,
    required this.lineTotalMinor,
    required this.createdAt,
    this.unitCostMinor,
    this.productName,
  });

  final String id;
  final String businessId;
  final String transactionId;
  final String productId;
  final int quantityMilli;
  final int unitPriceMinor;
  final int? unitCostMinor;
  final int lineTotalMinor;
  final DateTime createdAt;
  final String? productName;

  factory SaleLine.fromMap(Map<String, dynamic> row) {
    return SaleLine(
      id: row['id'] as String,
      businessId: row['business_id'] as String,
      transactionId: row['transaction_id'] as String,
      productId: row['product_id'] as String,
      quantityMilli: (row['quantity_milli'] as num).toInt(),
      unitPriceMinor: (row['unit_price_minor'] as num).toInt(),
      unitCostMinor: (row['unit_cost_minor'] as num?)?.toInt(),
      lineTotalMinor: (row['line_total_minor'] as num).toInt(),
      createdAt: _stamp(row['created_at']),
      productName: row['product_name'] as String?,
    );
  }

  static DateTime _stamp(Object raw) {
    if (raw is DateTime) {
      return raw.toUtc();
    }
    return DateTime.parse(raw.toString()).toUtc();
  }
}

class SaleLineDraft {
  const SaleLineDraft({
    required this.productId,
    required this.productName,
    required this.quantityText,
    required this.unitPriceText,
  });

  final String productId;
  final String productName;
  final String quantityText;
  final String unitPriceText;
}
