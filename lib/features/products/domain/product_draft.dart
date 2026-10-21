import '../../../core/inventory/unit_of_measure.dart';

class ProductDraft {
  const ProductDraft({
    required this.name,
    required this.sellingPriceText,
    required this.unitOfMeasure,
    this.sku = '',
    this.description = '',
    this.unitCostText = '',
    this.lowStockThresholdText = '',
    this.openingQuantityText = '',
    this.openingUnitCostText = '',
    this.openingIdempotencyKey,
    this.isActive = true,
    this.existingId,
  });

  final String name;
  final String sku;
  final String description;
  final String sellingPriceText;
  final String unitCostText;
  final String lowStockThresholdText;
  final String openingQuantityText;
  final String openingUnitCostText;
  final String? openingIdempotencyKey;
  final UnitOfMeasure unitOfMeasure;
  final bool isActive;
  final String? existingId;

  bool get isEdit => existingId != null;
}
