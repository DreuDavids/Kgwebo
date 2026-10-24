import '../domain/catalog_product.dart';
import '../domain/product_draft.dart';
import '../domain/product_snapshot.dart';
import '../domain/sale_line.dart';
import '../domain/stock_movement.dart';
import '../domain/stock_movement_draft.dart';
import '../../../core/finance/ledger_entry.dart';
import '../../transactions/domain/business_transaction.dart';
import '../../transactions/domain/payment_method.dart';

class RecordedProductSale {
  const RecordedProductSale({
    required this.transaction,
    required this.items,
    required this.products,
  });

  final BusinessTransaction transaction;
  final List<SaleLine> items;
  final List<CatalogProduct> products;
}

abstract class ProductRepository {
  Future<ProductListSnapshot> listAllConfirmed({
    required String ownerId,
    required String businessId,
    void Function(ProductListSnapshot cached)? onLocalCache,
  });

  Future<CatalogProduct?> findById({
    required String ownerId,
    required String businessId,
    required String productId,
  });

  Future<CatalogProduct> create({
    required String ownerId,
    required String businessId,
    required ProductDraft draft,
  });

  Future<CatalogProduct> update({
    required String ownerId,
    required String businessId,
    required ProductDraft draft,
  });

  Future<void> archive({
    required String ownerId,
    required String businessId,
    required String productId,
  });

  Future<void> delete({
    required String ownerId,
    required String businessId,
    required String productId,
  });

  Future<StockMovementListSnapshot> listMovements({
    required String ownerId,
    required String businessId,
    String? productId,
  });

  Future<StockMovement> recordMovement({
    required String ownerId,
    required String businessId,
    required String productId,
    required StockMovementDraft draft,
  });

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
  });

  Future<List<SaleLine>> listSaleLines({
    required String ownerId,
    required String businessId,
    required String transactionId,
  });
}
