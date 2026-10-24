import '../../../core/finance/ledger_entry.dart';
import '../../authentication/domain/auth_failure.dart';
import '../../transactions/domain/payment_method.dart';
import '../application/product_repository.dart';
import '../domain/catalog_product.dart';
import '../domain/product_draft.dart';
import '../domain/product_snapshot.dart';
import '../domain/sale_line.dart';
import '../domain/stock_movement.dart';
import '../domain/stock_movement_draft.dart';

class PreviewProductRepository implements ProductRepository {
  static const _previewMessage =
      'Preview and demo modes do not write inventory to Supabase.';

  @override
  Future<ProductListSnapshot> listAllConfirmed({
    required String ownerId,
    required String businessId,
    void Function(ProductListSnapshot cached)? onLocalCache,
  }) async {
    return const ProductListSnapshot(
      items: [],
      origin: InventoryDataOrigin.remote,
    );
  }

  @override
  Future<CatalogProduct?> findById({
    required String ownerId,
    required String businessId,
    required String productId,
  }) async {
    return null;
  }

  @override
  Future<CatalogProduct> create({
    required String ownerId,
    required String businessId,
    required ProductDraft draft,
  }) async {
    throw const AuthFailure(_previewMessage);
  }

  @override
  Future<CatalogProduct> update({
    required String ownerId,
    required String businessId,
    required ProductDraft draft,
  }) async {
    throw const AuthFailure(_previewMessage);
  }

  @override
  Future<void> archive({
    required String ownerId,
    required String businessId,
    required String productId,
  }) async {
    throw const AuthFailure(_previewMessage);
  }

  @override
  Future<void> delete({
    required String ownerId,
    required String businessId,
    required String productId,
  }) async {
    throw const AuthFailure(_previewMessage);
  }

  @override
  Future<StockMovementListSnapshot> listMovements({
    required String ownerId,
    required String businessId,
    String? productId,
  }) async {
    return const StockMovementListSnapshot(
      items: [],
      origin: InventoryDataOrigin.remote,
    );
  }

  @override
  Future<StockMovement> recordMovement({
    required String ownerId,
    required String businessId,
    required String productId,
    required StockMovementDraft draft,
  }) async {
    throw const AuthFailure(_previewMessage);
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
    throw const AuthFailure(_previewMessage);
  }

  @override
  Future<List<SaleLine>> listSaleLines({
    required String ownerId,
    required String businessId,
    required String transactionId,
  }) async {
    return const [];
  }
}
