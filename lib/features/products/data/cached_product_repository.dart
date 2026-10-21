import '../../../core/logging/app_logger.dart';
import '../../../core/persistence/product_cache.dart';
import '../../authentication/domain/auth_failure.dart';
import '../../transactions/domain/payment_method.dart';
import '../../../core/finance/ledger_entry.dart';
import '../application/product_repository.dart';
import '../domain/catalog_product.dart';
import '../domain/product_draft.dart';
import '../domain/product_snapshot.dart';
import '../domain/sale_line.dart';
import '../domain/stock_movement.dart';
import '../domain/stock_movement_draft.dart';

class CachedProductRepository implements ProductRepository {
  CachedProductRepository({
    required ProductRepository remote,
    required ProductCache cache,
    required String? Function() currentOwnerId,
  }) : _remote = remote,
       _cache = cache,
       _currentOwnerId = currentOwnerId;

  final ProductRepository _remote;
  final ProductCache _cache;
  final String? Function() _currentOwnerId;

  @override
  Future<ProductListSnapshot> listAllConfirmed({
    required String ownerId,
    required String businessId,
  }) async {
    _requireOwner(ownerId);
    try {
      final remote = await _remote.listAllConfirmed(
        ownerId: ownerId,
        businessId: businessId,
      );
      await _cache.replaceProductsForBusiness(
        ownerId: ownerId,
        businessId: businessId,
        products: remote.items,
      );
      return remote;
    } on AuthFailure catch (error) {
      if (!error.isRetryable) {
        rethrow;
      }
      final cached = await _cache.listProducts(
        ownerId: ownerId,
        businessId: businessId,
      );
      if (cached.isEmpty) {
        rethrow;
      }
      AppLogger.info(
        'Using confirmed product cache after a remote read failure.',
      );
      return ProductListSnapshot.stale(
        items: cached,
        refreshError: error.message,
      );
    }
  }

  @override
  Future<CatalogProduct?> findById({
    required String ownerId,
    required String businessId,
    required String productId,
  }) async {
    _requireOwner(ownerId);
    try {
      final remote = await _remote.findById(
        ownerId: ownerId,
        businessId: businessId,
        productId: productId,
      );
      if (remote != null) {
        await _cache.upsertProduct(remote);
      }
      return remote;
    } on AuthFailure catch (error) {
      if (!error.isRetryable) {
        rethrow;
      }
      final cached = await _cache.findProduct(
        ownerId: ownerId,
        businessId: businessId,
        productId: productId,
      );
      if (cached == null) {
        rethrow;
      }
      return cached;
    }
  }

  @override
  Future<CatalogProduct> create({
    required String ownerId,
    required String businessId,
    required ProductDraft draft,
  }) async {
    _requireOwner(ownerId);
    final saved = await _remote.create(
      ownerId: ownerId,
      businessId: businessId,
      draft: draft,
    );
    await _cache.upsertProduct(saved);
    return saved;
  }

  @override
  Future<CatalogProduct> update({
    required String ownerId,
    required String businessId,
    required ProductDraft draft,
  }) async {
    _requireOwner(ownerId);
    final saved = await _remote.update(
      ownerId: ownerId,
      businessId: businessId,
      draft: draft,
    );
    await _cache.upsertProduct(saved);
    return saved;
  }

  @override
  Future<void> archive({
    required String ownerId,
    required String businessId,
    required String productId,
  }) async {
    _requireOwner(ownerId);
    await _remote.archive(
      ownerId: ownerId,
      businessId: businessId,
      productId: productId,
    );
    final existing = await _cache.findProduct(
      ownerId: ownerId,
      businessId: businessId,
      productId: productId,
    );
    if (existing != null) {
      await _cache.upsertProduct(
        CatalogProduct(
          id: existing.id,
          businessId: existing.businessId,
          ownerId: existing.ownerId,
          createdBy: existing.createdBy,
          name: existing.name,
          sku: existing.sku,
          description: existing.description,
          sellingPriceMinor: existing.sellingPriceMinor,
          unitCostMinor: existing.unitCostMinor,
          stockQuantityMilli: existing.stockQuantityMilli,
          lowStockThresholdMilli: existing.lowStockThresholdMilli,
          unitOfMeasure: existing.unitOfMeasure,
          isActive: false,
          createdAt: existing.createdAt,
          updatedAt: DateTime.now().toUtc(),
        ),
      );
    }
  }

  @override
  Future<void> delete({
    required String ownerId,
    required String businessId,
    required String productId,
  }) async {
    _requireOwner(ownerId);
    await _remote.delete(
      ownerId: ownerId,
      businessId: businessId,
      productId: productId,
    );
    await _cache.deleteProduct(
      ownerId: ownerId,
      businessId: businessId,
      productId: productId,
    );
  }

  @override
  Future<StockMovementListSnapshot> listMovements({
    required String ownerId,
    required String businessId,
    String? productId,
  }) async {
    _requireOwner(ownerId);
    try {
      final remote = await _remote.listMovements(
        ownerId: ownerId,
        businessId: businessId,
        productId: productId,
      );
      await _cache.upsertMovements(remote.items);
      return remote;
    } on AuthFailure catch (error) {
      if (!error.isRetryable) {
        rethrow;
      }
      final cached = await _cache.listMovements(
        ownerId: ownerId,
        businessId: businessId,
        productId: productId,
      );
      if (cached.isEmpty) {
        rethrow;
      }
      AppLogger.info(
        'Using confirmed stock movement cache after a remote read failure.',
      );
      return StockMovementListSnapshot.stale(
        items: cached,
        refreshError: error.message,
      );
    }
  }

  @override
  Future<StockMovement> recordMovement({
    required String ownerId,
    required String businessId,
    required String productId,
    required StockMovementDraft draft,
  }) async {
    _requireOwner(ownerId);
    final saved = await _remote.recordMovement(
      ownerId: ownerId,
      businessId: businessId,
      productId: productId,
      draft: draft,
    );
    await _cache.upsertMovements([saved]);
    final product = await _remote.findById(
      ownerId: ownerId,
      businessId: businessId,
      productId: productId,
    );
    if (product != null) {
      await _cache.upsertProduct(product);
    }
    return saved;
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
    _requireOwner(ownerId);
    final saved = await _remote.recordProductSale(
      ownerId: ownerId,
      businessId: businessId,
      currencyCode: currencyCode,
      idempotencyKey: idempotencyKey,
      occurredOn: occurredOn,
      category: category,
      description: description,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      lines: lines,
    );
    await _cache.upsertProducts(saved.products);
    return saved;
  }

  @override
  Future<List<SaleLine>> listSaleLines({
    required String ownerId,
    required String businessId,
    required String transactionId,
  }) {
    _requireOwner(ownerId);
    return _remote.listSaleLines(
      ownerId: ownerId,
      businessId: businessId,
      transactionId: transactionId,
    );
  }

  void _requireOwner(String ownerId) {
    final current = _currentOwnerId();
    if (current == null) {
      throw AuthFailure.fromCode('session_expired');
    }
    if (current != ownerId) {
      throw const AuthFailure(
        'This business does not belong to the signed-in account.',
      );
    }
  }
}
