import 'dart:async';

import 'package:kgwebo/core/finance/ledger_entry.dart';
import 'package:kgwebo/core/inventory/inventory_costing.dart';
import 'package:kgwebo/core/inventory/quantity_formatter.dart';
import 'package:kgwebo/core/inventory/quantity_parser.dart';
import 'package:kgwebo/core/inventory/unit_of_measure.dart';
import 'package:kgwebo/core/money/money_parser.dart';
import 'package:kgwebo/features/authentication/domain/auth_failure.dart';
import 'package:kgwebo/features/products/application/product_repository.dart';
import 'package:kgwebo/features/products/application/product_validators.dart';
import 'package:kgwebo/features/products/domain/catalog_product.dart';
import 'package:kgwebo/features/products/domain/product_draft.dart';
import 'package:kgwebo/features/products/domain/product_snapshot.dart';
import 'package:kgwebo/features/products/domain/sale_line.dart';
import 'package:kgwebo/features/products/domain/stock_movement.dart';
import 'package:kgwebo/features/products/domain/stock_movement_draft.dart';
import 'package:kgwebo/features/products/domain/stock_movement_type.dart';
import 'package:kgwebo/features/transactions/domain/business_transaction.dart';
import 'package:kgwebo/features/transactions/domain/payment_method.dart';

CatalogProduct sampleProduct({
  String id = 'prod-1',
  String ownerId = 'user-1',
  String businessId = 'biz-1',
  String name = 'Tomatoes',
  String? sku,
  int sellingPriceMinor = 1250,
  int? unitCostMinor = 800,
  int stockQuantityMilli = 5000,
  int? lowStockThresholdMilli = 2000,
  UnitOfMeasure unitOfMeasure = UnitOfMeasure.kilogram,
  bool isActive = true,
}) {
  final now = DateTime.utc(2026, 10, 21, 8);
  return CatalogProduct(
    id: id,
    businessId: businessId,
    ownerId: ownerId,
    createdBy: ownerId,
    name: name,
    sku: sku,
    sellingPriceMinor: sellingPriceMinor,
    unitCostMinor: unitCostMinor,
    stockQuantityMilli: stockQuantityMilli,
    lowStockThresholdMilli: lowStockThresholdMilli,
    unitOfMeasure: unitOfMeasure,
    isActive: isActive,
    createdAt: now,
    updatedAt: now,
  );
}

class FakeProductRepository implements ProductRepository {
  FakeProductRepository({
    this.ownerId = 'user-1',
    this.businessId = 'biz-1',
    List<CatalogProduct>? products,
  }) : products = products ?? [];

  final String ownerId;
  final String businessId;
  final List<CatalogProduct> products;
  final List<StockMovement> movements = [];
  final List<SaleLine> saleLines = [];
  final List<BusinessTransaction> sales = [];
  AuthFailure? nextError;
  AuthFailure? failReads;
  String? staleError;
  Completer<void>? listAllGate;
  bool allowAnyOwner = false;
  int createCalls = 0;
  int movementCalls = 0;
  int saleCalls = 0;
  int listCalls = 0;
  int listAllCalls = 0;

  Completer<void> armListAllGate() {
    listAllGate = Completer<void>();
    return listAllGate!;
  }

  @override
  Future<ProductListSnapshot> listAllConfirmed({
    required String ownerId,
    required String businessId,
    void Function(ProductListSnapshot cached)? onLocalCache,
  }) async {
    listCalls += 1;
    listAllCalls += 1;
    _require(ownerId, businessId);
    final owned =
        products
            .where(
              (item) =>
                  item.belongsTo(ownerId: ownerId, businessId: businessId),
            )
            .toList();
    if (owned.isNotEmpty) {
      onLocalCache?.call(
        ProductListSnapshot(
          items: owned,
          origin: InventoryDataOrigin.localCache,
        ),
      );
    }
    final gate = listAllGate;
    if (gate != null) {
      await gate.future;
    }
    _throwIfNeeded(failReads ?? nextError);
    if (staleError != null) {
      return ProductListSnapshot.stale(items: owned, refreshError: staleError!);
    }
    return ProductListSnapshot.remote(owned);
  }

  @override
  Future<CatalogProduct?> findById({
    required String ownerId,
    required String businessId,
    required String productId,
  }) async {
    _throwIfNeeded(failReads ?? nextError);
    _require(ownerId, businessId);
    for (final item in products) {
      if (item.id == productId &&
          item.belongsTo(ownerId: ownerId, businessId: businessId)) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<CatalogProduct> create({
    required String ownerId,
    required String businessId,
    required ProductDraft draft,
  }) async {
    createCalls += 1;
    _throwIfNeeded();
    _require(ownerId, businessId);
    final errors = validateProductDraft(draft);
    if (errors.hasErrors) {
      throw const AuthFailure('Invalid product.');
    }
    final now = DateTime.now().toUtc();
    var product = CatalogProduct(
      id: 'prod-${products.length + 1}',
      businessId: businessId,
      ownerId: ownerId,
      createdBy: ownerId,
      name: draft.name.trim(),
      sku: draft.sku.trim().isEmpty ? null : draft.sku.trim(),
      description:
          draft.description.trim().isEmpty ? null : draft.description.trim(),
      sellingPriceMinor: tryParseMinorUnits(draft.sellingPriceText)!,
      unitCostMinor:
          draft.unitCostText.trim().isEmpty
              ? null
              : tryParseMinorUnits(draft.unitCostText),
      stockQuantityMilli: 0,
      lowStockThresholdMilli:
          draft.lowStockThresholdText.trim().isEmpty
              ? null
              : tryParseQuantityMilli(
                draft.lowStockThresholdText,
                unit: draft.unitOfMeasure,
              ),
      unitOfMeasure: draft.unitOfMeasure,
      isActive: draft.isActive,
      createdAt: now,
      updatedAt: now,
    );
    products.add(product);
    final openingText = draft.openingQuantityText.trim();
    if (openingText.isNotEmpty) {
      await recordMovement(
        ownerId: ownerId,
        businessId: businessId,
        productId: product.id,
        draft: StockMovementDraft(
          type: StockMovementType.opening,
          quantityText: openingText,
          unitCostText: draft.openingUnitCostText,
          idempotencyKey: draft.openingIdempotencyKey ?? 'open-${product.id}',
        ),
      );
      product = products.firstWhere((item) => item.id == product.id);
    }
    return product;
  }

  @override
  Future<CatalogProduct> update({
    required String ownerId,
    required String businessId,
    required ProductDraft draft,
  }) async {
    _throwIfNeeded();
    _require(ownerId, businessId);
    final existingId = draft.existingId;
    if (existingId == null) {
      throw const AuthFailure('Missing product.');
    }
    final index = products.indexWhere(
      (item) =>
          item.id == existingId &&
          item.belongsTo(ownerId: ownerId, businessId: businessId),
    );
    if (index < 0) {
      throw const AuthFailure('Missing product.');
    }
    final current = products[index];
    final updated = CatalogProduct(
      id: current.id,
      businessId: current.businessId,
      ownerId: current.ownerId,
      createdBy: current.createdBy,
      name: draft.name.trim(),
      sku: draft.sku.trim().isEmpty ? null : draft.sku.trim(),
      description:
          draft.description.trim().isEmpty ? null : draft.description.trim(),
      sellingPriceMinor: tryParseMinorUnits(draft.sellingPriceText)!,
      unitCostMinor:
          draft.unitCostText.trim().isEmpty
              ? null
              : tryParseMinorUnits(draft.unitCostText),
      stockQuantityMilli: current.stockQuantityMilli,
      lowStockThresholdMilli:
          draft.lowStockThresholdText.trim().isEmpty
              ? null
              : tryParseQuantityMilli(
                draft.lowStockThresholdText,
                unit: draft.unitOfMeasure,
              ),
      unitOfMeasure: draft.unitOfMeasure,
      isActive: draft.isActive,
      createdAt: current.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
    products[index] = updated;
    return updated;
  }

  @override
  Future<void> archive({
    required String ownerId,
    required String businessId,
    required String productId,
  }) async {
    _throwIfNeeded();
    _require(ownerId, businessId);
    final index = products.indexWhere((item) => item.id == productId);
    if (index < 0) {
      throw const AuthFailure('Missing product.');
    }
    final current = products[index];
    products[index] = CatalogProduct(
      id: current.id,
      businessId: current.businessId,
      ownerId: current.ownerId,
      createdBy: current.createdBy,
      name: current.name,
      sku: current.sku,
      description: current.description,
      sellingPriceMinor: current.sellingPriceMinor,
      unitCostMinor: current.unitCostMinor,
      stockQuantityMilli: current.stockQuantityMilli,
      lowStockThresholdMilli: current.lowStockThresholdMilli,
      unitOfMeasure: current.unitOfMeasure,
      isActive: false,
      createdAt: current.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<void> delete({
    required String ownerId,
    required String businessId,
    required String productId,
  }) async {
    _throwIfNeeded();
    _require(ownerId, businessId);
    if (movements.any((item) => item.productId == productId) ||
        saleLines.any((item) => item.productId == productId)) {
      throw const AuthFailure(
        'This product has stock or sale history. Archive it instead of deleting it.',
      );
    }
    products.removeWhere((item) => item.id == productId);
  }

  @override
  Future<StockMovementListSnapshot> listMovements({
    required String ownerId,
    required String businessId,
    String? productId,
  }) async {
    _throwIfNeeded(failReads ?? nextError);
    _require(ownerId, businessId);
    final items =
        movements.where((item) {
          if (!item.belongsTo(ownerId: ownerId, businessId: businessId)) {
            return false;
          }
          if (productId != null && item.productId != productId) {
            return false;
          }
          return true;
        }).toList();
    return StockMovementListSnapshot.remote(items);
  }

  @override
  Future<StockMovement> recordMovement({
    required String ownerId,
    required String businessId,
    required String productId,
    required StockMovementDraft draft,
  }) async {
    movementCalls += 1;
    _throwIfNeeded();
    _require(ownerId, businessId);
    final errors = validateStockMovementDraft(draft);
    if (errors.hasErrors) {
      throw const AuthFailure('Invalid stock movement.');
    }
    for (final existing in movements) {
      if (existing.idempotencyKey == draft.idempotencyKey &&
          existing.belongsTo(ownerId: ownerId, businessId: businessId)) {
        return existing;
      }
    }
    final productIndex = products.indexWhere(
      (item) =>
          item.id == productId &&
          item.belongsTo(ownerId: ownerId, businessId: businessId),
    );
    if (productIndex < 0) {
      throw const AuthFailure('Missing product.');
    }
    final product = products[productIndex];
    final quantity = tryParseQuantityMilli(
      draft.quantityText,
      unit: product.unitOfMeasure,
      allowZero: false,
    );
    if (quantity == null) {
      throw const AuthFailure('Invalid quantity.');
    }
    var delta = quantity * draft.type.quantityDeltaSign;
    if (draft.type == StockMovementType.reversal) {
      final original = movements.cast<StockMovement?>().firstWhere(
        (item) => item?.id == draft.reversesMovementId,
        orElse: () => null,
      );
      if (original == null) {
        throw const AuthFailure('Original movement was not found.');
      }
      if (movements.any((item) => item.reversesMovementId == original.id)) {
        throw const AuthFailure(
          'This stock movement has already been reversed.',
        );
      }
      delta = -original.quantityDeltaMilli;
    }
    final next = InventoryCosting.applyStockDelta(
      currentQuantityMilli: product.stockQuantityMilli,
      deltaMilli: delta,
    );
    final costText = draft.unitCostText.trim();
    final incomingCost = costText.isEmpty ? null : tryParseMinorUnits(costText);
    var unitCost = product.unitCostMinor;
    if (draft.type.recordsIncomingCost && incomingCost != null) {
      unitCost = InventoryCosting.weightedAverageUnitCostMinor(
        currentQuantityMilli: product.stockQuantityMilli,
        currentUnitCostMinor: product.unitCostMinor,
        incomingQuantityMilli: quantity,
        incomingUnitCostMinor: incomingCost,
      );
    }
    final movement = StockMovement(
      id: 'mov-${movements.length + 1}',
      businessId: businessId,
      productId: productId,
      ownerId: ownerId,
      createdBy: ownerId,
      idempotencyKey: draft.idempotencyKey,
      type: draft.type,
      quantityMilli: quantity,
      quantityDeltaMilli: delta,
      resultingQuantityMilli: next,
      unitCostMinor: incomingCost ?? product.unitCostMinor,
      reason: draft.reason.trim().isEmpty ? null : draft.reason.trim(),
      notes: draft.notes.trim().isEmpty ? null : draft.notes.trim(),
      createdAt: DateTime.now().toUtc(),
      reversesMovementId: draft.reversesMovementId,
    );
    movements.add(movement);
    products[productIndex] = CatalogProduct(
      id: product.id,
      businessId: product.businessId,
      ownerId: product.ownerId,
      createdBy: product.createdBy,
      name: product.name,
      sku: product.sku,
      description: product.description,
      sellingPriceMinor: product.sellingPriceMinor,
      unitCostMinor: unitCost,
      stockQuantityMilli: next,
      lowStockThresholdMilli: product.lowStockThresholdMilli,
      unitOfMeasure: product.unitOfMeasure,
      isActive: product.isActive,
      createdAt: product.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
    return movement;
  }

  @override
  Future<RecordedProductSale> recordProductSale({
    required String ownerId,
    required String businessId,
    required String currencyCode,
    required String idempotencyKey,
    required DateTime occurredOn,
    required String category,
    required String description,
    required PaymentMethod paymentMethod,
    required PaymentStatus paymentStatus,
    required List<SaleLineDraft> lines,
  }) async {
    saleCalls += 1;
    _throwIfNeeded();
    _require(ownerId, businessId);
    for (final existing in sales) {
      if (existing.idempotencyKey == idempotencyKey) {
        return RecordedProductSale(
          transaction: existing,
          items:
              saleLines
                  .where((item) => item.transactionId == existing.id)
                  .toList(),
          products:
              products
                  .where(
                    (item) => item.belongsTo(
                      ownerId: ownerId,
                      businessId: businessId,
                    ),
                  )
                  .toList(),
        );
      }
    }
    if (lines.isEmpty) {
      throw const AuthFailure('Add at least one product to this sale.');
    }
    final reservedByProduct = <String, int>{};
    final prepared =
        <
          ({
            CatalogProduct product,
            int quantityMilli,
            int unitPriceMinor,
            int lineTotalMinor,
          })
        >[];
    var total = 0;
    for (final line in lines) {
      final product = products.firstWhere(
        (item) =>
            item.id == line.productId &&
            item.belongsTo(ownerId: ownerId, businessId: businessId),
        orElse: () => throw const AuthFailure('Missing product.'),
      );
      final quantity = tryParseQuantityMilli(
        line.quantityText,
        unit: product.unitOfMeasure,
        allowZero: false,
      );
      final price = tryParseMinorUnits(line.unitPriceText);
      if (quantity == null || price == null) {
        throw const AuthFailure('Invalid sale line.');
      }
      final reserved = reservedByProduct[product.id] ?? 0;
      InventoryCosting.applyStockDelta(
        currentQuantityMilli: product.stockQuantityMilli - reserved,
        deltaMilli: -quantity,
      );
      reservedByProduct[product.id] = reserved + quantity;
      final lineTotal = InventoryCosting.lineTotalMinor(
        quantityMilli: quantity,
        unitPriceMinor: price,
      );
      total += lineTotal;
      prepared.add((
        product: product,
        quantityMilli: quantity,
        unitPriceMinor: price,
        lineTotalMinor: lineTotal,
      ));
    }
    final createdLines = <SaleLine>[];
    for (final line in prepared) {
      await recordMovement(
        ownerId: ownerId,
        businessId: businessId,
        productId: line.product.id,
        draft: StockMovementDraft(
          type: StockMovementType.sold,
          quantityText: QuantityFormatter.format(line.quantityMilli),
          idempotencyKey: '$idempotencyKey-${line.product.id}',
        ),
      );
      createdLines.add(
        SaleLine(
          id: 'line-${saleLines.length + createdLines.length + 1}',
          businessId: businessId,
          transactionId: 'sale-${sales.length + 1}',
          productId: line.product.id,
          quantityMilli: line.quantityMilli,
          unitPriceMinor: line.unitPriceMinor,
          unitCostMinor: line.product.unitCostMinor,
          lineTotalMinor: line.lineTotalMinor,
          createdAt: DateTime.now().toUtc(),
          productName: line.product.name,
        ),
      );
    }
    final transaction = BusinessTransaction(
      id: 'sale-${sales.length + 1}',
      businessId: businessId,
      ownerId: ownerId,
      createdBy: ownerId,
      idempotencyKey: idempotencyKey,
      type: MoneyMovementType.sale,
      amountMinor: total,
      currencyCode: currencyCode,
      category: category,
      description: description.trim().isEmpty ? null : description.trim(),
      occurredAt: occurredOn.toUtc(),
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    sales.add(transaction);
    saleLines.addAll(
      createdLines.map(
        (line) => SaleLine(
          id: line.id,
          businessId: line.businessId,
          transactionId: transaction.id,
          productId: line.productId,
          quantityMilli: line.quantityMilli,
          unitPriceMinor: line.unitPriceMinor,
          unitCostMinor: line.unitCostMinor,
          lineTotalMinor: line.lineTotalMinor,
          createdAt: line.createdAt,
          productName: line.productName,
        ),
      ),
    );
    return RecordedProductSale(
      transaction: transaction,
      items:
          saleLines
              .where((item) => item.transactionId == transaction.id)
              .toList(),
      products:
          products
              .where(
                (item) =>
                    item.belongsTo(ownerId: ownerId, businessId: businessId),
              )
              .toList(),
    );
  }

  @override
  Future<List<SaleLine>> listSaleLines({
    required String ownerId,
    required String businessId,
    required String transactionId,
  }) async {
    _require(ownerId, businessId);
    return saleLines
        .where(
          (item) =>
              item.businessId == businessId &&
              item.transactionId == transactionId,
        )
        .toList();
  }

  void _throwIfNeeded([AuthFailure? error]) {
    final pending = error ?? nextError;
    if (pending != null) {
      final thrown = pending;
      nextError = null;
      throw thrown;
    }
  }

  void _require(String ownerId, String businessId) {
    if (allowAnyOwner) {
      return;
    }
    if (ownerId != this.ownerId || businessId != this.businessId) {
      throw const AuthFailure(
        'This business does not belong to the signed-in account.',
      );
    }
  }
}
