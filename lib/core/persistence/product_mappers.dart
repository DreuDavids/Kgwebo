import 'package:drift/drift.dart';

import '../../features/products/domain/catalog_product.dart';
import '../../features/products/domain/stock_movement.dart';
import '../../features/products/domain/stock_movement_type.dart';
import '../../features/products/domain/unit_of_measure.dart';
import 'business_mappers.dart';
import 'kgwebo_database.dart';

CatalogProduct catalogProductFromCached(CachedProduct row) {
  if (row.ownerId.isEmpty || row.businessId.isEmpty) {
    throw StateError('Refusing a cache row without owner and business ids.');
  }
  if (row.syncStatus != confirmedSyncStatus) {
    throw StateError('Refusing an unverified product cache row.');
  }
  return CatalogProduct(
    id: row.remoteId,
    businessId: row.businessId,
    ownerId: row.ownerId,
    createdBy: row.createdBy,
    name: row.name,
    sku: row.sku,
    description: row.description,
    sellingPriceMinor: row.sellingPriceMinor,
    unitCostMinor: row.unitCostMinor,
    stockQuantityMilli: row.stockQuantityMilli,
    lowStockThresholdMilli: row.lowStockThresholdMilli,
    unitOfMeasure: UnitOfMeasureX.fromStorage(row.unitOfMeasure),
    isActive: row.isActive,
    createdAt: row.createdAt.toUtc(),
    updatedAt: row.updatedAt.toUtc(),
  );
}

CachedProductsCompanion cachedCompanionFromProduct(CatalogProduct product) {
  return CachedProductsCompanion.insert(
    remoteId: product.id,
    ownerId: product.ownerId,
    businessId: product.businessId,
    createdBy: product.createdBy,
    name: product.name,
    sku: Value(product.sku),
    description: Value(product.description),
    sellingPriceMinor: product.sellingPriceMinor,
    unitCostMinor: Value(product.unitCostMinor),
    stockQuantityMilli: product.stockQuantityMilli,
    lowStockThresholdMilli: Value(product.lowStockThresholdMilli),
    unitOfMeasure: product.unitOfMeasure.storageValue,
    isActive: product.isActive,
    createdAt: product.createdAt.toUtc(),
    updatedAt: product.updatedAt.toUtc(),
    cachedAt: DateTime.now().toUtc(),
    syncStatus: const Value(confirmedSyncStatus),
  );
}

StockMovement stockMovementFromCached(CachedStockMovement row) {
  if (row.ownerId.isEmpty || row.businessId.isEmpty) {
    throw StateError('Refusing a cache row without owner and business ids.');
  }
  if (row.syncStatus != confirmedSyncStatus) {
    throw StateError('Refusing an unverified stock movement cache row.');
  }
  return StockMovement(
    id: row.remoteId,
    businessId: row.businessId,
    productId: row.productId,
    ownerId: row.ownerId,
    createdBy: row.createdBy,
    idempotencyKey: row.idempotencyKey,
    type: StockMovementType.fromStorage(row.movementType),
    quantityMilli: row.quantityMilli,
    quantityDeltaMilli: row.quantityDeltaMilli,
    resultingQuantityMilli: row.resultingQuantityMilli,
    unitCostMinor: row.unitCostMinor,
    reason: row.reason,
    notes: row.notes,
    reference: row.reference,
    transactionId: row.transactionId,
    reversesMovementId: row.reversesMovementId,
    createdAt: row.createdAt.toUtc(),
  );
}

CachedStockMovementsCompanion cachedCompanionFromMovement(
  StockMovement movement,
) {
  return CachedStockMovementsCompanion.insert(
    remoteId: movement.id,
    ownerId: movement.ownerId,
    businessId: movement.businessId,
    productId: movement.productId,
    createdBy: movement.createdBy,
    idempotencyKey: movement.idempotencyKey,
    movementType: movement.type.storageValue,
    quantityMilli: movement.quantityMilli,
    quantityDeltaMilli: movement.quantityDeltaMilli,
    resultingQuantityMilli: movement.resultingQuantityMilli,
    unitCostMinor: Value(movement.unitCostMinor),
    reason: Value(movement.reason),
    notes: Value(movement.notes),
    reference: Value(movement.reference),
    transactionId: Value(movement.transactionId),
    reversesMovementId: Value(movement.reversesMovementId),
    createdAt: movement.createdAt.toUtc(),
    cachedAt: DateTime.now().toUtc(),
    syncStatus: const Value(confirmedSyncStatus),
  );
}
