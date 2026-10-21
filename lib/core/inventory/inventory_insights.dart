import '../../features/products/domain/catalog_product.dart';
import 'inventory_costing.dart';
import 'stock_status.dart';

class InventoryInsights {
  const InventoryInsights({
    required this.activeCount,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.missingCostCount,
    required this.estimatedValueMinor,
    required this.restockProductIds,
    this.missingCostProductIds = const [],
  });

  final int activeCount;
  final int lowStockCount;
  final int outOfStockCount;
  final int missingCostCount;
  final int estimatedValueMinor;
  final List<String> restockProductIds;
  final List<String> missingCostProductIds;

  factory InventoryInsights.fromProducts(Iterable<CatalogProduct> products) {
    var activeCount = 0;
    var lowStockCount = 0;
    var outOfStockCount = 0;
    var missingCostCount = 0;
    var estimatedValueMinor = 0;
    final restockProductIds = <String>[];
    final missingCostProductIds = <String>[];

    for (final product in products) {
      if (!product.isActive) {
        continue;
      }
      activeCount += 1;
      if (!product.hasRecordedCost) {
        missingCostCount += 1;
        missingCostProductIds.add(product.id);
      } else {
        estimatedValueMinor +=
            InventoryCosting.estimatedValueMinor(
              quantityMilli: product.stockQuantityMilli,
              unitCostMinor: product.unitCostMinor,
            ) ??
            0;
      }
      switch (product.availability) {
        case StockAvailability.outOfStock:
          outOfStockCount += 1;
          restockProductIds.add(product.id);
        case StockAvailability.lowStock:
          lowStockCount += 1;
          restockProductIds.add(product.id);
        case StockAvailability.inStock:
          break;
      }
    }

    return InventoryInsights(
      activeCount: activeCount,
      lowStockCount: lowStockCount,
      outOfStockCount: outOfStockCount,
      missingCostCount: missingCostCount,
      estimatedValueMinor: estimatedValueMinor,
      restockProductIds: restockProductIds,
      missingCostProductIds: missingCostProductIds,
    );
  }
}
