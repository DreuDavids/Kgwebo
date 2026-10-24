import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/ledger_entry.dart';
import 'package:kgwebo/core/persistence/kgwebo_database.dart';
import 'package:kgwebo/core/persistence/product_cache.dart';
import 'package:kgwebo/core/sync/outbox_store.dart';
import 'package:kgwebo/features/authentication/domain/auth_failure.dart';
import 'package:kgwebo/features/products/data/cached_product_repository.dart';
import 'package:kgwebo/features/products/domain/sale_line.dart';
import 'package:kgwebo/features/products/domain/stock_movement_draft.dart';
import 'package:kgwebo/features/products/domain/stock_movement_type.dart';
import 'package:kgwebo/features/transactions/domain/payment_method.dart';

import '../../helpers/fake_products.dart';

void main() {
  late FakeProductRepository remote;
  late KgweboDatabase database;
  late OutboxStore outbox;
  late CachedProductRepository repository;

  setUp(() {
    remote = FakeProductRepository(products: [sampleProduct()]);
    database = KgweboDatabase.memory();
    outbox = OutboxStore(database);
    repository = CachedProductRepository(
      remote: remote,
      cache: ProductCache(database),
      currentOwnerId: () => 'user-1',
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('product sales are not queued after a network failure', () async {
    remote.nextError = const AuthFailure.network();
    expect(
      () => repository.recordProductSale(
        ownerId: 'user-1',
        businessId: 'biz-1',
        currencyCode: 'BWP',
        idempotencyKey: 'sale-offline',
        occurredOn: DateTime.utc(2026, 10, 21),
        category: 'goods',
        description: '',
        paymentMethod: PaymentMethod.cash,
        paymentStatus: PaymentStatus.paid,
        lines: const [
          SaleLineDraft(
            productId: 'prod-1',
            productName: 'Tomatoes',
            quantityText: '1',
            unitPriceText: '12.50',
          ),
        ],
      ),
      throwsA(
        isA<AuthFailure>().having(
          (error) => error.isRetryable,
          'retryable',
          true,
        ),
      ),
    );
    expect(remote.saleCalls, 1);
    expect(remote.sales, isEmpty);
    expect(
      await ProductCache(
        database,
      ).listProducts(ownerId: 'user-1', businessId: 'biz-1'),
      isEmpty,
    );
    expect(await outbox.listForOwner('user-1'), isEmpty);
  });

  test(
    'findById uses a cached product after a retryable remote failure',
    () async {
      await repository.listAllConfirmed(ownerId: 'user-1', businessId: 'biz-1');
      remote.nextError = const AuthFailure.network();
      final found = await repository.findById(
        ownerId: 'user-1',
        businessId: 'biz-1',
        productId: 'prod-1',
      );
      expect(found?.id, 'prod-1');
      expect(found?.name, 'Tomatoes');
    },
  );

  test(
    'listMovements stays readable after a retryable failure with an empty cache',
    () async {
      remote.nextError = const AuthFailure.network();
      final snapshot = await repository.listMovements(
        ownerId: 'user-1',
        businessId: 'biz-1',
        productId: 'prod-1',
      );
      expect(snapshot.items, isEmpty);
      expect(snapshot.isStale, isTrue);
      expect(snapshot.refreshError, isNotNull);
    },
  );

  test('stock movements are not queued after a network failure', () async {
    remote.nextError = const AuthFailure.network();
    expect(
      () => repository.recordMovement(
        ownerId: 'user-1',
        businessId: 'biz-1',
        productId: 'prod-1',
        draft: const StockMovementDraft(
          type: StockMovementType.received,
          quantityText: '2',
          unitCostText: '9.00',
          idempotencyKey: 'recv-offline',
        ),
      ),
      throwsA(isA<AuthFailure>()),
    );
    expect(remote.movementCalls, 1);
    expect(remote.movements, isEmpty);
    expect(await outbox.listForOwner('user-1'), isEmpty);
  });
}
