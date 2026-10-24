import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/finance/business_calendar.dart';
import '../../../core/finance/ledger_entry.dart';
import '../../../core/inventory/inventory_costing.dart';
import '../../../core/inventory/quantity_parser.dart';
import '../../../core/money/money_parser.dart';
import '../../authentication/domain/auth_failure.dart';
import '../../transactions/domain/business_transaction.dart';
import '../../transactions/domain/payment_method.dart';
import '../application/product_repository.dart';
import '../application/product_validators.dart';
import '../domain/catalog_product.dart';
import '../domain/product_draft.dart';
import '../domain/product_snapshot.dart';
import '../domain/sale_line.dart';
import '../domain/stock_movement.dart';
import '../domain/stock_movement_draft.dart';
import '../domain/unit_of_measure.dart';
import 'product_write_map.dart';

class SupabaseProductRepository implements ProductRepository {
  SupabaseProductRepository(this._client);

  final SupabaseClient _client;

  static const _products = 'products';
  static const _movements = 'stock_movements';
  static const _saleItems = 'sale_items';

  @override
  Future<ProductListSnapshot> listAllConfirmed({
    required String ownerId,
    required String businessId,
    void Function(ProductListSnapshot cached)? onLocalCache,
  }) async {
    _requireOwner(ownerId);
    try {
      final rows = await _client
          .from(_products)
          .select()
          .eq('business_id', businessId)
          .order('name', ascending: true)
          .order('id', ascending: true);
      return ProductListSnapshot.remote([
        for (final row in rows)
          _ownedProduct(
            CatalogProduct.fromMap(row, ownerId: ownerId),
            ownerId,
            businessId,
          ),
      ]);
    } catch (error) {
      throw _mapError(error);
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
      final row =
          await _client
              .from(_products)
              .select()
              .eq('id', productId)
              .eq('business_id', businessId)
              .maybeSingle();
      if (row == null) {
        return null;
      }
      return _ownedProduct(
        CatalogProduct.fromMap(row, ownerId: ownerId),
        ownerId,
        businessId,
      );
    } catch (error) {
      throw _mapError(error);
    }
  }

  @override
  Future<CatalogProduct> create({
    required String ownerId,
    required String businessId,
    required ProductDraft draft,
  }) async {
    _requireOwner(ownerId);
    final errors = validateProductDraft(draft);
    if (errors.hasErrors) {
      throw const AuthFailure(
        'Check the product name, prices and quantities and try again.',
      );
    }
    final sellingPrice = tryParseMinorUnits(draft.sellingPriceText)!;
    final unitCostText = draft.unitCostText.trim();
    final unitCost =
        unitCostText.isEmpty ? null : tryParseMinorUnits(unitCostText);
    final thresholdText = draft.lowStockThresholdText.trim();
    final threshold =
        thresholdText.isEmpty
            ? null
            : tryParseQuantityMilli(thresholdText, unit: draft.unitOfMeasure);
    final openingText = draft.openingQuantityText.trim();
    final opening =
        openingText.isEmpty
            ? null
            : tryParseQuantityMilli(
              openingText,
              unit: draft.unitOfMeasure,
              allowZero: false,
            );
    final openingCostText = draft.openingUnitCostText.trim();
    final openingCost =
        openingCostText.isEmpty ? null : tryParseMinorUnits(openingCostText);
    try {
      final result = await _client.rpc(
        'create_catalog_product',
        params: {
          'p_business_id': businessId,
          'p_name': draft.name.trim(),
          'p_selling_price_minor': sellingPrice,
          'p_unit_of_measure': draft.unitOfMeasure.storageValue,
          'p_sku': draft.sku.trim().isEmpty ? null : draft.sku.trim(),
          'p_description':
              draft.description.trim().isEmpty
                  ? null
                  : draft.description.trim(),
          'p_unit_cost_minor': unitCost,
          'p_low_stock_threshold_milli': threshold,
          'p_opening_quantity_milli': opening,
          'p_opening_unit_cost_minor': openingCost ?? unitCost,
          'p_opening_idempotency_key':
              opening == null ? null : draft.openingIdempotencyKey,
        },
      );
      final productMap = _rpcMap(result)['product'] as Map<String, dynamic>;
      return _ownedProduct(
        CatalogProduct.fromMap(productMap, ownerId: ownerId),
        ownerId,
        businessId,
      );
    } catch (error) {
      throw _mapError(error);
    }
  }

  @override
  Future<CatalogProduct> update({
    required String ownerId,
    required String businessId,
    required ProductDraft draft,
  }) async {
    _requireOwner(ownerId);
    final existingId = draft.existingId;
    if (existingId == null) {
      throw const AuthFailure('This product could not be updated.');
    }
    final errors = validateProductDraft(draft);
    if (errors.hasErrors) {
      throw const AuthFailure(
        'Check the product name, prices and quantities and try again.',
      );
    }
    try {
      final updated =
          await _client
              .from(_products)
              .update(productUpdateMap(draft))
              .eq('id', existingId)
              .eq('business_id', businessId)
              .select()
              .maybeSingle();
      if (updated == null) {
        throw const AuthFailure(
          'Could not update this product. It may not exist or you may not own it.',
        );
      }
      final saved = _ownedProduct(
        CatalogProduct.fromMap(updated, ownerId: ownerId),
        ownerId,
        businessId,
      );
      if (saved.id != existingId) {
        throw const AuthFailure(
          'The server returned a different product than the one being edited.',
        );
      }
      return saved;
    } catch (error) {
      throw _mapError(error);
    }
  }

  @override
  Future<void> archive({
    required String ownerId,
    required String businessId,
    required String productId,
  }) async {
    _requireOwner(ownerId);
    try {
      final updated =
          await _client
              .from(_products)
              .update({'is_active': false})
              .eq('id', productId)
              .eq('business_id', businessId)
              .select('id')
              .maybeSingle();
      if (updated == null) {
        throw const AuthFailure(
          'Could not archive this product. It may not exist or you may not own it.',
        );
      }
    } catch (error) {
      throw _mapError(error);
    }
  }

  @override
  Future<void> delete({
    required String ownerId,
    required String businessId,
    required String productId,
  }) async {
    _requireOwner(ownerId);
    try {
      final deleted =
          await _client
              .from(_products)
              .delete()
              .eq('id', productId)
              .eq('business_id', businessId)
              .select('id')
              .maybeSingle();
      if (deleted == null) {
        throw const AuthFailure(
          'Could not delete this product. It may not exist or you may not own it.',
        );
      }
    } catch (error) {
      throw _mapError(error);
    }
  }

  @override
  Future<StockMovementListSnapshot> listMovements({
    required String ownerId,
    required String businessId,
    String? productId,
  }) async {
    _requireOwner(ownerId);
    try {
      var query = _client
          .from(_movements)
          .select()
          .eq('business_id', businessId);
      if (productId != null) {
        query = query.eq('product_id', productId);
      }
      final rows = await query
          .order('created_at', ascending: false)
          .order('id', ascending: false)
          .limit(200);
      return StockMovementListSnapshot.remote([
        for (final row in rows)
          _ownedMovement(
            StockMovement.fromMap(row, ownerId: ownerId),
            ownerId,
            businessId,
          ),
      ]);
    } catch (error) {
      throw _mapError(error);
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
    final errors = validateStockMovementDraft(draft);
    if (errors.hasErrors) {
      throw const AuthFailure('Check the quantity and reason and try again.');
    }
    final quantity =
        tryParseQuantityMilli(draft.quantityText, allowZero: false)!;
    final costText = draft.unitCostText.trim();
    final unitCost = costText.isEmpty ? null : tryParseMinorUnits(costText);
    try {
      final result = await _client.rpc(
        'record_stock_movement',
        params: {
          'p_business_id': businessId,
          'p_product_id': productId,
          'p_movement_type': draft.type.storageValue,
          'p_quantity_milli': quantity,
          'p_idempotency_key': draft.idempotencyKey,
          'p_unit_cost_minor': unitCost,
          'p_reason': draft.reason.trim().isEmpty ? null : draft.reason.trim(),
          'p_notes': draft.notes.trim().isEmpty ? null : draft.notes.trim(),
          'p_reference':
              draft.reference.trim().isEmpty ? null : draft.reference.trim(),
          'p_reverses_movement_id': draft.reversesMovementId,
        },
      );
      final map = _rpcMap(result);
      return _ownedMovement(
        StockMovement.fromMap(
          map['movement'] as Map<String, dynamic>,
          ownerId: ownerId,
        ),
        ownerId,
        businessId,
      );
    } catch (error) {
      throw _mapError(error);
    }
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
    if (lines.isEmpty) {
      throw const AuthFailure('Add at least one product to this sale.');
    }
    final payload = <Map<String, dynamic>>[];
    for (final line in lines) {
      final quantity = tryParseQuantityMilli(
        line.quantityText,
        allowZero: false,
      );
      final price = tryParseMinorUnits(line.unitPriceText);
      if (quantity == null || price == null) {
        throw const AuthFailure(
          'Check each product quantity and selling price.',
        );
      }
      InventoryCosting.lineTotalMinor(
        quantityMilli: quantity,
        unitPriceMinor: price,
      );
      payload.add({
        'product_id': line.productId,
        'quantity_milli': quantity,
        'unit_price_minor': price,
      });
    }
    try {
      final result = await _client.rpc(
        'record_product_sale',
        params: {
          'p_business_id': businessId,
          'p_idempotency_key': idempotencyKey,
          'p_occurred_at':
              BusinessCalendar.utcFromGaborone(
                year: occurredOn.year,
                month: occurredOn.month,
                day: occurredOn.day,
              ).toIso8601String(),
          'p_category': category,
          'p_description':
              description.trim().isEmpty ? null : description.trim(),
          'p_payment_method': paymentMethod.storageValue,
          'p_payment_status': BusinessTransaction.statusToStorage(
            paymentStatus,
          ),
          'p_lines': payload,
        },
      );
      final map = _rpcMap(result);
      final transaction = _ownedTransaction(
        BusinessTransaction.fromMap(
          map['transaction'] as Map<String, dynamic>,
          ownerId: ownerId,
        ),
        ownerId,
        businessId,
      );
      final items = [
        for (final row in (map['items'] as List<dynamic>? ?? const []))
          SaleLine.fromMap(Map<String, dynamic>.from(row as Map)),
      ];
      final products = [
        for (final row in (map['products'] as List<dynamic>? ?? const []))
          _ownedProduct(
            CatalogProduct.fromMap(
              Map<String, dynamic>.from(row as Map),
              ownerId: ownerId,
            ),
            ownerId,
            businessId,
          ),
      ];
      return RecordedProductSale(
        transaction: transaction,
        items: items,
        products: products,
      );
    } catch (error) {
      throw _mapError(error);
    }
  }

  @override
  Future<List<SaleLine>> listSaleLines({
    required String ownerId,
    required String businessId,
    required String transactionId,
  }) async {
    _requireOwner(ownerId);
    try {
      final rows = await _client
          .from(_saleItems)
          .select()
          .eq('business_id', businessId)
          .eq('transaction_id', transactionId)
          .order('id', ascending: true);
      return [for (final row in rows) SaleLine.fromMap(row)];
    } catch (error) {
      throw _mapError(error);
    }
  }

  Map<String, dynamic> _rpcMap(dynamic result) {
    if (result is Map<String, dynamic>) {
      return result;
    }
    if (result is Map) {
      return Map<String, dynamic>.from(result);
    }
    throw const AuthFailure(
      'The server returned an unexpected inventory result.',
    );
  }

  void _requireOwner(String ownerId) {
    final current = _client.auth.currentUser?.id;
    if (current == null) {
      throw AuthFailure.fromCode('session_expired');
    }
    if (current != ownerId) {
      throw const AuthFailure(
        'This business does not belong to the signed-in account.',
      );
    }
  }

  CatalogProduct _ownedProduct(
    CatalogProduct product,
    String ownerId,
    String businessId,
  ) {
    if (!product.belongsTo(ownerId: ownerId, businessId: businessId)) {
      throw const AuthFailure(
        'This product does not belong to the signed-in account.',
      );
    }
    return product;
  }

  StockMovement _ownedMovement(
    StockMovement movement,
    String ownerId,
    String businessId,
  ) {
    if (!movement.belongsTo(ownerId: ownerId, businessId: businessId)) {
      throw const AuthFailure(
        'This stock movement does not belong to the signed-in account.',
      );
    }
    return movement;
  }

  BusinessTransaction _ownedTransaction(
    BusinessTransaction transaction,
    String ownerId,
    String businessId,
  ) {
    if (!transaction.belongsTo(ownerId: ownerId, businessId: businessId)) {
      throw const AuthFailure(
        'This sale does not belong to the signed-in account.',
      );
    }
    return transaction;
  }

  AuthFailure _mapError(Object error) {
    if (error is AuthFailure) {
      return error;
    }
    if (error is PostgrestException) {
      final message = error.message;
      if (message.contains('enough stock')) {
        return const AuthFailure(
          'There is not enough stock for this movement.',
        );
      }
      if (message.contains('Archive this product')) {
        return const AuthFailure(
          'This product has stock or sale history. Archive it instead of deleting it.',
        );
      }
      if (message.contains('idempotency') || error.code == '23505') {
        return AuthFailure.fromMessage(message);
      }
      return AuthFailure.fromMessage(message);
    }
    if (error is SocketException ||
        error is TimeoutException ||
        error is AuthRetryableFetchException) {
      return const AuthFailure.network();
    }
    return AuthFailure.fromMessage(error.toString());
  }
}
