import '../../../core/inventory/quantity_parser.dart';
import '../../../core/money/money_parser.dart';
import '../domain/product_draft.dart';
import '../domain/unit_of_measure.dart';

Map<String, dynamic> productUpdateMap(ProductDraft draft) {
  final name = draft.name.trim();
  final sku = draft.sku.trim();
  final description = draft.description.trim();
  final sellingPrice = tryParseMinorUnits(draft.sellingPriceText);
  if (sellingPrice == null) {
    throw FormatException('Invalid selling price', draft.sellingPriceText);
  }
  final unitCostText = draft.unitCostText.trim();
  final unitCost =
      unitCostText.isEmpty ? null : tryParseMinorUnits(unitCostText);
  final thresholdText = draft.lowStockThresholdText.trim();
  final threshold =
      thresholdText.isEmpty
          ? null
          : tryParseQuantityMilli(thresholdText, unit: draft.unitOfMeasure);
  return {
    'name': name,
    'sku': sku.isEmpty ? null : sku,
    'description': description.isEmpty ? null : description,
    'selling_price_minor': sellingPrice,
    'unit_cost_minor': unitCost,
    'low_stock_threshold_milli': threshold,
    'unit_of_measure': draft.unitOfMeasure.storageValue,
    'is_active': draft.isActive,
  };
}
