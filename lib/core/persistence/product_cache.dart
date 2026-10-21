import 'package:drift/drift.dart';

import '../../features/products/domain/catalog_product.dart';
import '../../features/products/domain/stock_movement.dart';
import 'business_mappers.dart';
import 'kgwebo_database.dart';
import 'product_mappers.dart';

class ProductCache {
  ProductCache(this._db);

  final KgweboDatabase _db;

  Future<List<CatalogProduct>> listProducts({
    required String ownerId,
    required String businessId,
  }) async {
    if (ownerId.isEmpty || businessId.isEmpty) {
      return const [];
    }
    final rows =
        await (_db.select(_db.cachedProducts)
              ..where(
                (tbl) =>
                    tbl.ownerId.equals(ownerId) &
                    tbl.businessId.equals(businessId) &
                    tbl.syncStatus.equals(confirmedSyncStatus),
              )
              ..orderBy([
                (tbl) => OrderingTerm.asc(tbl.name),
                (tbl) => OrderingTerm.asc(tbl.remoteId),
              ]))
            .get();
    return rows.map(_ownedProduct(ownerId, businessId)).toList();
  }

  Future<CatalogProduct?> findProduct({
    required String ownerId,
    required String businessId,
    required String productId,
  }) async {
    if (ownerId.isEmpty || businessId.isEmpty || productId.isEmpty) {
      return null;
    }
    final row =
        await (_db.select(_db.cachedProducts)..where(
          (tbl) =>
              tbl.ownerId.equals(ownerId) &
              tbl.businessId.equals(businessId) &
              tbl.remoteId.equals(productId) &
              tbl.syncStatus.equals(confirmedSyncStatus),
        )).getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _ownedProduct(ownerId, businessId)(row);
  }

  Future<void> upsertProduct(CatalogProduct product) {
    return upsertProducts([product]);
  }

  Future<void> upsertProducts(List<CatalogProduct> products) async {
    if (products.isEmpty) {
      return;
    }
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.cachedProducts,
        products.map(cachedCompanionFromProduct).toList(),
      );
    });
  }

  Future<void> deleteProduct({
    required String ownerId,
    required String businessId,
    required String productId,
  }) async {
    if (ownerId.isEmpty || businessId.isEmpty || productId.isEmpty) {
      return;
    }
    await (_db.delete(_db.cachedProducts)..where(
      (tbl) =>
          tbl.ownerId.equals(ownerId) &
          tbl.businessId.equals(businessId) &
          tbl.remoteId.equals(productId),
    )).go();
  }

  Future<void> replaceProductsForBusiness({
    required String ownerId,
    required String businessId,
    required List<CatalogProduct> products,
  }) async {
    if (ownerId.isEmpty || businessId.isEmpty) {
      return;
    }
    await _db.transaction(() async {
      await (_db.delete(_db.cachedProducts)..where(
        (tbl) =>
            tbl.ownerId.equals(ownerId) & tbl.businessId.equals(businessId),
      )).go();
      if (products.isNotEmpty) {
        await _db.batch((batch) {
          batch.insertAllOnConflictUpdate(
            _db.cachedProducts,
            products.map(cachedCompanionFromProduct).toList(),
          );
        });
      }
    });
  }

  Future<List<StockMovement>> listMovements({
    required String ownerId,
    required String businessId,
    String? productId,
  }) async {
    if (ownerId.isEmpty || businessId.isEmpty) {
      return const [];
    }
    final rows =
        await (_db.select(_db.cachedStockMovements)
              ..where((tbl) {
                var expr =
                    tbl.ownerId.equals(ownerId) &
                    tbl.businessId.equals(businessId) &
                    tbl.syncStatus.equals(confirmedSyncStatus);
                if (productId != null && productId.isNotEmpty) {
                  expr = expr & tbl.productId.equals(productId);
                }
                return expr;
              })
              ..orderBy([
                (tbl) => OrderingTerm.desc(tbl.createdAt),
                (tbl) => OrderingTerm.desc(tbl.remoteId),
              ]))
            .get();
    return rows.map(_ownedMovement(ownerId, businessId)).toList();
  }

  Future<void> upsertMovements(List<StockMovement> movements) async {
    if (movements.isEmpty) {
      return;
    }
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.cachedStockMovements,
        movements.map(cachedCompanionFromMovement).toList(),
      );
    });
  }

  CatalogProduct Function(CachedProduct row) _ownedProduct(
    String ownerId,
    String businessId,
  ) {
    return (row) {
      final product = catalogProductFromCached(row);
      if (!product.belongsTo(ownerId: ownerId, businessId: businessId)) {
        throw StateError(
          'Cache query returned a product for a different owner or business.',
        );
      }
      return product;
    };
  }

  StockMovement Function(CachedStockMovement row) _ownedMovement(
    String ownerId,
    String businessId,
  ) {
    return (row) {
      final movement = stockMovementFromCached(row);
      if (!movement.belongsTo(ownerId: ownerId, businessId: businessId)) {
        throw StateError(
          'Cache query returned a stock movement for a different owner or business.',
        );
      }
      return movement;
    };
  }
}
