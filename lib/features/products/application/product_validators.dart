import '../../../core/inventory/quantity_parser.dart';
import '../../../core/money/money_parser.dart';
import '../domain/product_draft.dart';
import '../domain/stock_movement_draft.dart';

class ProductFieldErrors {
  const ProductFieldErrors({
    this.name,
    this.sku,
    this.description,
    this.sellingPrice,
    this.unitCost,
    this.lowStockThreshold,
    this.openingQuantity,
    this.openingUnitCost,
  });

  final String? name;
  final String? sku;
  final String? description;
  final String? sellingPrice;
  final String? unitCost;
  final String? lowStockThreshold;
  final String? openingQuantity;
  final String? openingUnitCost;

  bool get hasErrors =>
      name != null ||
      sku != null ||
      description != null ||
      sellingPrice != null ||
      unitCost != null ||
      lowStockThreshold != null ||
      openingQuantity != null ||
      openingUnitCost != null;
}

class StockMovementFieldErrors {
  const StockMovementFieldErrors({
    this.quantity,
    this.unitCost,
    this.reason,
    this.notes,
  });

  final String? quantity;
  final String? unitCost;
  final String? reason;
  final String? notes;

  bool get hasErrors =>
      quantity != null || unitCost != null || reason != null || notes != null;
}

ProductFieldErrors validateProductDraft(ProductDraft draft) {
  final name = draft.name.trim();
  final sku = draft.sku.trim();
  final description = draft.description.trim();
  final sellingPrice = tryParseMinorUnits(draft.sellingPriceText);
  final unitCostText = draft.unitCostText.trim();
  final unitCost =
      unitCostText.isEmpty ? null : tryParseMinorUnits(unitCostText);
  final thresholdText = draft.lowStockThresholdText.trim();
  final threshold =
      thresholdText.isEmpty
          ? null
          : tryParseQuantityMilli(thresholdText, unit: draft.unitOfMeasure);
  final openingText = draft.openingQuantityText.trim();
  final opening =
      openingText.isEmpty
          ? null
          : tryParseQuantityMilli(
            openingText,
            unit: draft.unitOfMeasure,
            allowZero: false,
          );
  final openingCostText = draft.openingUnitCostText.trim();
  final openingCost =
      openingCostText.isEmpty ? null : tryParseMinorUnits(openingCostText);

  return ProductFieldErrors(
    name:
        name.isEmpty || name.length > 120
            ? 'Enter a product name, up to 120 characters.'
            : null,
    sku: sku.length > 40 ? 'Keep the product code under 40 characters.' : null,
    description:
        description.length > 500
            ? 'Keep the description under 500 characters.'
            : null,
    sellingPrice:
        sellingPrice == null
            ? 'Enter a positive selling price, for example 12.50.'
            : null,
    unitCost:
        unitCostText.isEmpty
            ? null
            : (unitCost == null
                ? 'Enter a cost of 0.01 or more, or leave cost blank.'
                : null),
    lowStockThreshold:
        thresholdText.isEmpty
            ? null
            : (threshold == null
                ? 'Enter a whole or fractional quantity that matches the unit.'
                : null),
    openingQuantity:
        openingText.isEmpty
            ? null
            : (opening == null
                ? 'Enter how many units you already have, using the product unit.'
                : null),
    openingUnitCost:
        openingCostText.isEmpty
            ? null
            : (openingCost == null
                ? 'Enter the cost of this opening stock, or leave it blank.'
                : null),
  );
}

StockMovementFieldErrors validateStockMovementDraft(StockMovementDraft draft) {
  final quantity = tryParseQuantityMilli(draft.quantityText, allowZero: false);
  final costText = draft.unitCostText.trim();
  final unitCost = costText.isEmpty ? null : tryParseMinorUnits(costText);
  final reason = draft.reason.trim();
  final notes = draft.notes.trim();

  return StockMovementFieldErrors(
    quantity:
        quantity == null ? 'Enter how many units this movement covers.' : null,
    unitCost:
        costText.isEmpty
            ? null
            : (unitCost == null
                ? 'Enter a cost of 0.01 or more, or leave cost blank.'
                : null),
    reason:
        draft.type.requiresReason && reason.isEmpty
            ? 'Enter a reason for this correction or write-off.'
            : (reason.length > 200
                ? 'Keep the reason under 200 characters.'
                : null),
    notes: notes.length > 500 ? 'Keep the note under 500 characters.' : null,
  );
}
