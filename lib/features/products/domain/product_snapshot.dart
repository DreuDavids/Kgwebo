import 'catalog_product.dart';
import 'stock_movement.dart';

enum InventoryDataOrigin { remote, localCache }

class ProductListSnapshot {
  const ProductListSnapshot({
    required this.items,
    required this.origin,
    this.refreshError,
  });

  factory ProductListSnapshot.remote(List<CatalogProduct> items) {
    return ProductListSnapshot(
      items: items,
      origin: InventoryDataOrigin.remote,
    );
  }

  factory ProductListSnapshot.fromCache(List<CatalogProduct> items) {
    return ProductListSnapshot(
      items: items,
      origin: InventoryDataOrigin.localCache,
    );
  }

  factory ProductListSnapshot.stale({
    required List<CatalogProduct> items,
    required String refreshError,
  }) {
    return ProductListSnapshot(
      items: items,
      origin: InventoryDataOrigin.localCache,
      refreshError: refreshError,
    );
  }

  final List<CatalogProduct> items;
  final InventoryDataOrigin origin;
  final String? refreshError;

  bool get isStale => origin == InventoryDataOrigin.localCache;
}

class StockMovementListSnapshot {
  const StockMovementListSnapshot({
    required this.items,
    required this.origin,
    this.refreshError,
  });

  factory StockMovementListSnapshot.remote(List<StockMovement> items) {
    return StockMovementListSnapshot(
      items: items,
      origin: InventoryDataOrigin.remote,
    );
  }

  factory StockMovementListSnapshot.stale({
    required List<StockMovement> items,
    required String refreshError,
  }) {
    return StockMovementListSnapshot(
      items: items,
      origin: InventoryDataOrigin.localCache,
      refreshError: refreshError,
    );
  }

  final List<StockMovement> items;
  final InventoryDataOrigin origin;
  final String? refreshError;

  bool get isStale => origin == InventoryDataOrigin.localCache;
}
