import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/inventory/inventory_costing.dart';
import 'package:kgwebo/core/inventory/inventory_insights.dart';
import 'package:kgwebo/core/inventory/quantity.dart';
import 'package:kgwebo/core/inventory/quantity_formatter.dart';
import 'package:kgwebo/core/inventory/quantity_parser.dart';
import 'package:kgwebo/core/inventory/stock_status.dart';
import 'package:kgwebo/features/products/domain/catalog_product.dart';
import 'package:kgwebo/features/products/domain/unit_of_measure.dart';

void main() {
  group('quantity parser', () {
    test('parses whole and fractional units without binary floats', () {
      expect(tryParseQuantityMilli('1'), Quantity.milliScale);
      expect(tryParseQuantityMilli('2.5'), 2500);
      expect(tryParseQuantityMilli('0.125'), 125);
      expect(tryParseQuantityMilli('1,000.5'), 1000500);
      expect(tryParseQuantityMilli('0'), 0);
    });

    test('rejects negatives, extra decimals, and scientific notation', () {
      expect(tryParseQuantityMilli('-1'), isNull);
      expect(tryParseQuantityMilli('1.0001'), isNull);
      expect(tryParseQuantityMilli('1e2'), isNull);
      expect(tryParseQuantityMilli(''), isNull);
    });

    test('rejects fractional quantities for each and pack', () {
      expect(tryParseQuantityMilli('1.5', unit: UnitOfMeasure.each), isNull);
      expect(tryParseQuantityMilli('2', unit: UnitOfMeasure.pack), 2000);
      expect(tryParseQuantityMilli('0.5', unit: UnitOfMeasure.kilogram), 500);
    });
  });

  group('quantity formatter', () {
    test('formats milli-units with up to three decimals', () {
      expect(QuantityFormatter.format(1000), '1');
      expect(QuantityFormatter.format(2500), '2.5');
      expect(QuantityFormatter.format(125), '0.125');
      expect(QuantityFormatter.format(0), '0');
    });
  });

  group('stock availability', () {
    test('zero stock is out of stock even when the threshold is zero', () {
      expect(
        stockAvailability(quantityMilli: 0, lowStockThresholdMilli: 0),
        StockAvailability.outOfStock,
      );
      expect(
        stockAvailability(quantityMilli: 0, lowStockThresholdMilli: null),
        StockAvailability.outOfStock,
      );
    });

    test('quantity at or below a positive threshold is low stock', () {
      expect(
        stockAvailability(quantityMilli: 2000, lowStockThresholdMilli: 2000),
        StockAvailability.lowStock,
      );
      expect(
        stockAvailability(quantityMilli: 1000, lowStockThresholdMilli: 2000),
        StockAvailability.lowStock,
      );
      expect(
        stockAvailability(quantityMilli: 3000, lowStockThresholdMilli: 2000),
        StockAvailability.inStock,
      );
    });
  });

  group('inventory costing', () {
    test('weighted average uses recorded restock cost', () {
      expect(
        InventoryCosting.weightedAverageUnitCostMinor(
          currentQuantityMilli: 2000,
          currentUnitCostMinor: 1000,
          incomingQuantityMilli: 2000,
          incomingUnitCostMinor: 2000,
        ),
        1500,
      );
    });

    test('empty stock takes the incoming cost', () {
      expect(
        InventoryCosting.weightedAverageUnitCostMinor(
          currentQuantityMilli: 0,
          currentUnitCostMinor: 1000,
          incomingQuantityMilli: 3000,
          incomingUnitCostMinor: 700,
        ),
        700,
      );
    });

    test('estimated value is null when cost is missing', () {
      expect(
        InventoryCosting.estimatedValueMinor(
          quantityMilli: 5000,
          unitCostMinor: null,
        ),
        isNull,
      );
      expect(
        InventoryCosting.estimatedValueMinor(
          quantityMilli: 2500,
          unitCostMinor: 400,
        ),
        1000,
      );
    });

    test('sale line total and COGS use snapshotted prices', () {
      expect(
        InventoryCosting.lineTotalMinor(
          quantityMilli: 2500,
          unitPriceMinor: 400,
        ),
        1000,
      );
      expect(
        InventoryCosting.lineCogsMinor(quantityMilli: 2500, unitCostMinor: 200),
        500,
      );
      expect(
        InventoryCosting.lineCogsMinor(
          quantityMilli: 2500,
          unitCostMinor: null,
        ),
        isNull,
      );
    });

    test('historical sale COGS stays frozen after a later cost change', () {
      const soldQuantityMilli = 1000;
      const snapshottedCost = 500;
      const laterProductCost = 800;
      expect(
        InventoryCosting.lineCogsMinor(
          quantityMilli: soldQuantityMilli,
          unitCostMinor: snapshottedCost,
        ),
        500,
      );
      expect(
        InventoryCosting.lineCogsMinor(
          quantityMilli: soldQuantityMilli,
          unitCostMinor: laterProductCost,
        ),
        isNot(500),
      );
    });

    test('stock delta cannot go negative', () {
      expect(
        InventoryCosting.applyStockDelta(
          currentQuantityMilli: 1000,
          deltaMilli: -1000,
        ),
        0,
      );
      expect(
        () => InventoryCosting.applyStockDelta(
          currentQuantityMilli: 1000,
          deltaMilli: -1001,
        ),
        throwsA(isA<InsufficientStockException>()),
      );
    });

    test('reversal restores the prior balance', () {
      const start = 5000;
      final afterSale = InventoryCosting.applyStockDelta(
        currentQuantityMilli: start,
        deltaMilli: -2000,
      );
      expect(afterSale, 3000);
      expect(
        InventoryCosting.applyStockDelta(
          currentQuantityMilli: afterSale,
          deltaMilli: 2000,
        ),
        start,
      );
    });
  });

  group('inventory insights', () {
    test('counts active, low, out of stock and flags missing cost', () {
      final insights = InventoryInsights.fromProducts([
        _product(id: 'a', quantityMilli: 5000, cost: 100, threshold: 1000),
        _product(id: 'b', quantityMilli: 500, cost: 200, threshold: 1000),
        _product(id: 'c', quantityMilli: 0, cost: 300, threshold: 0),
        _product(id: 'd', quantityMilli: 2000, cost: null, threshold: 1000),
        _product(id: 'e', quantityMilli: 1000, cost: 400, isActive: false),
      ]);

      expect(insights.activeCount, 4);
      expect(insights.lowStockCount, 1);
      expect(insights.outOfStockCount, 1);
      expect(insights.missingCostCount, 1);
      expect(insights.estimatedValueMinor, 500 + 100);
      expect(insights.restockProductIds, ['b', 'c']);
      expect(insights.missingCostProductIds, ['d']);
    });
  });
}

CatalogProduct _product({
  required String id,
  required int quantityMilli,
  required int? cost,
  int? threshold,
  bool isActive = true,
}) {
  return CatalogProduct(
    id: id,
    businessId: 'biz-1',
    ownerId: 'user-1',
    createdBy: 'user-1',
    name: id,
    sellingPriceMinor: 1000,
    unitCostMinor: cost,
    stockQuantityMilli: quantityMilli,
    lowStockThresholdMilli: threshold,
    unitOfMeasure: UnitOfMeasure.each,
    isActive: isActive,
    createdAt: DateTime.utc(2026, 10, 21),
    updatedAt: DateTime.utc(2026, 10, 21),
  );
}
