import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/features/products/application/product_validators.dart';
import 'package:kgwebo/features/products/domain/product_draft.dart';
import 'package:kgwebo/features/products/domain/stock_movement_draft.dart';
import 'package:kgwebo/features/products/domain/stock_movement_type.dart';
import 'package:kgwebo/features/products/domain/unit_of_measure.dart';

void main() {
  group('product draft', () {
    test('requires a name and positive selling price', () {
      final errors = validateProductDraft(
        const ProductDraft(
          name: '',
          sellingPriceText: '',
          unitOfMeasure: UnitOfMeasure.each,
        ),
      );
      expect(errors.name, isNotNull);
      expect(errors.sellingPrice, isNotNull);
    });

    test('allows a missing SKU and missing cost', () {
      final errors = validateProductDraft(
        const ProductDraft(
          name: 'Tomatoes',
          sellingPriceText: '12.50',
          unitOfMeasure: UnitOfMeasure.kilogram,
        ),
      );
      expect(errors.hasErrors, isFalse);
    });

    test('rejects negative prices and invalid quantities', () {
      final errors = validateProductDraft(
        const ProductDraft(
          name: 'Oil',
          sku: 'OIL-1',
          sellingPriceText: '-1.00',
          unitCostText: '-0.50',
          lowStockThresholdText: '-1',
          unitOfMeasure: UnitOfMeasure.litre,
        ),
      );
      expect(errors.sellingPrice, isNotNull);
      expect(errors.unitCost, isNotNull);
      expect(errors.lowStockThreshold, isNotNull);
    });

    test('rejects fractional each units for opening stock', () {
      final errors = validateProductDraft(
        const ProductDraft(
          name: 'Soap',
          sellingPriceText: '8.00',
          openingQuantityText: '1.5',
          unitOfMeasure: UnitOfMeasure.each,
        ),
      );
      expect(errors.openingQuantity, isNotNull);
    });
  });

  group('stock movement draft', () {
    test('requires a reason for manual corrections and write-offs', () {
      expect(
        validateStockMovementDraft(
          const StockMovementDraft(
            type: StockMovementType.adjustmentDecrease,
            quantityText: '1',
            reason: '',
          ),
        ).reason,
        isNotNull,
      );
      expect(
        validateStockMovementDraft(
          const StockMovementDraft(
            type: StockMovementType.damaged,
            quantityText: '1',
            reason: '',
          ),
        ).reason,
        isNotNull,
      );
      expect(
        validateStockMovementDraft(
          const StockMovementDraft(
            type: StockMovementType.received,
            quantityText: '4',
            unitCostText: '10.00',
          ),
        ).hasErrors,
        isFalse,
      );
    });

    test('customer returns increase stock; damaged returns do not', () {
      expect(StockMovementType.customerReturn.quantityDeltaSign, 1);
      expect(StockMovementType.returnDamaged.quantityDeltaSign, 0);
      expect(StockMovementType.sold.quantityDeltaSign, -1);
      expect(StockMovementType.received.quantityDeltaSign, 1);
    });
  });
}
