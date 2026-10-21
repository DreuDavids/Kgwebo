import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/ledger_entry.dart';
import 'package:kgwebo/core/inventory/inventory_costing.dart';
import 'package:kgwebo/features/authentication/domain/auth_failure.dart';
import 'package:kgwebo/features/products/domain/sale_line.dart';
import 'package:kgwebo/features/products/domain/stock_movement_draft.dart';
import 'package:kgwebo/features/products/domain/stock_movement_type.dart';
import 'package:kgwebo/features/transactions/domain/payment_method.dart';

import '../../helpers/fake_products.dart';

void main() {
  test(
    'stock received increases quantity once for the same idempotency key',
    () async {
      final repo = FakeProductRepository(products: [sampleProduct()]);
      const draft = StockMovementDraft(
        type: StockMovementType.received,
        quantityText: '2',
        unitCostText: '9.00',
        idempotencyKey: 'recv-1',
      );
      await repo.recordMovement(
        ownerId: 'user-1',
        businessId: 'biz-1',
        productId: 'prod-1',
        draft: draft,
      );
      await repo.recordMovement(
        ownerId: 'user-1',
        businessId: 'biz-1',
        productId: 'prod-1',
        draft: draft,
      );
      final product = await repo.findById(
        ownerId: 'user-1',
        businessId: 'biz-1',
        productId: 'prod-1',
      );
      expect(product!.stockQuantityMilli, 7000);
      expect(repo.movements, hasLength(1));
    },
  );

  test('insufficient stock cannot produce a negative balance', () async {
    final repo = FakeProductRepository(
      products: [sampleProduct(stockQuantityMilli: 1000)],
    );
    expect(
      () => repo.recordMovement(
        ownerId: 'user-1',
        businessId: 'biz-1',
        productId: 'prod-1',
        draft: const StockMovementDraft(
          type: StockMovementType.sold,
          quantityText: '2',
          idempotencyKey: 'sold-1',
        ),
      ),
      throwsA(isA<InsufficientStockException>()),
    );
  });

  test(
    'product sale decreases stock once and unpaid sales still reduce stock',
    () async {
      final repo = FakeProductRepository(products: [sampleProduct()]);
      const lines = [
        SaleLineDraft(
          productId: 'prod-1',
          productName: 'Tomatoes',
          quantityText: '1',
          unitPriceText: '12.50',
        ),
      ];
      final paid = await repo.recordProductSale(
        ownerId: 'user-1',
        businessId: 'biz-1',
        currencyCode: 'BWP',
        idempotencyKey: 'sale-paid',
        occurredOn: DateTime.utc(2026, 10, 21),
        category: 'goods',
        description: '',
        paymentMethod: PaymentMethod.cash,
        paymentStatus: PaymentStatus.paid,
        lines: lines,
      );
      expect(paid.transaction.amountMinor, 1250);
      expect(paid.transaction.paymentStatus, PaymentStatus.paid);

      final duplicate = await repo.recordProductSale(
        ownerId: 'user-1',
        businessId: 'biz-1',
        currencyCode: 'BWP',
        idempotencyKey: 'sale-paid',
        occurredOn: DateTime.utc(2026, 10, 21),
        category: 'goods',
        description: '',
        paymentMethod: PaymentMethod.cash,
        paymentStatus: PaymentStatus.paid,
        lines: lines,
      );
      expect(duplicate.transaction.id, paid.transaction.id);

      await repo.recordProductSale(
        ownerId: 'user-1',
        businessId: 'biz-1',
        currencyCode: 'BWP',
        idempotencyKey: 'sale-unpaid',
        occurredOn: DateTime.utc(2026, 10, 21),
        category: 'goods',
        description: '',
        paymentMethod: PaymentMethod.cash,
        paymentStatus: PaymentStatus.unpaid,
        lines: lines,
      );

      final product = await repo.findById(
        ownerId: 'user-1',
        businessId: 'biz-1',
        productId: 'prod-1',
      );
      expect(product!.stockQuantityMilli, 3000);
      expect(repo.sales, hasLength(2));
    },
  );

  test('owner isolation rejects another business', () async {
    final repo = FakeProductRepository(products: [sampleProduct()]);
    expect(
      () => repo.listAllConfirmed(ownerId: 'user-b', businessId: 'biz-b'),
      throwsA(isA<AuthFailure>()),
    );
  });

  test(
    'failed product sale does not leave a partial sale or stock change',
    () async {
      final repo = FakeProductRepository(
        products: [
          sampleProduct(),
          sampleProduct(id: 'prod-2', name: 'Soap', stockQuantityMilli: 0),
        ],
      );
      expect(
        () => repo.recordProductSale(
          ownerId: 'user-1',
          businessId: 'biz-1',
          currencyCode: 'BWP',
          idempotencyKey: 'sale-partial',
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
            SaleLineDraft(
              productId: 'prod-2',
              productName: 'Soap',
              quantityText: '1',
              unitPriceText: '8.00',
            ),
          ],
        ),
        throwsA(isA<InsufficientStockException>()),
      );
      expect(repo.sales, isEmpty);
      expect(repo.movements, isEmpty);
      expect(repo.saleLines, isEmpty);
      final tomatoes = await repo.findById(
        ownerId: 'user-1',
        businessId: 'biz-1',
        productId: 'prod-1',
      );
      expect(tomatoes!.stockQuantityMilli, 5000);
    },
  );

  test('sale line cost stays frozen after the product cost changes', () async {
    final repo = FakeProductRepository(products: [sampleProduct()]);
    final sold = await repo.recordProductSale(
      ownerId: 'user-1',
      businessId: 'biz-1',
      currencyCode: 'BWP',
      idempotencyKey: 'sale-cogs',
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
    );
    expect(sold.items.single.unitCostMinor, 800);
    await repo.recordMovement(
      ownerId: 'user-1',
      businessId: 'biz-1',
      productId: 'prod-1',
      draft: const StockMovementDraft(
        type: StockMovementType.received,
        quantityText: '2',
        unitCostText: '20.00',
        idempotencyKey: 'recv-cost',
      ),
    );
    final product = await repo.findById(
      ownerId: 'user-1',
      businessId: 'biz-1',
      productId: 'prod-1',
    );
    expect(product!.unitCostMinor, isNot(800));
    expect(sold.items.single.unitCostMinor, 800);
  });

  test(
    'resellable returns increase stock and damaged returns do not',
    () async {
      final repo = FakeProductRepository(products: [sampleProduct()]);
      await repo.recordMovement(
        ownerId: 'user-1',
        businessId: 'biz-1',
        productId: 'prod-1',
        draft: const StockMovementDraft(
          type: StockMovementType.customerReturn,
          quantityText: '1',
          idempotencyKey: 'ret-ok',
        ),
      );
      await repo.recordMovement(
        ownerId: 'user-1',
        businessId: 'biz-1',
        productId: 'prod-1',
        draft: const StockMovementDraft(
          type: StockMovementType.returnDamaged,
          quantityText: '1',
          reason: 'Crushed in transit',
          idempotencyKey: 'ret-bad',
        ),
      );
      final product = await repo.findById(
        ownerId: 'user-1',
        businessId: 'biz-1',
        productId: 'prod-1',
      );
      expect(product!.stockQuantityMilli, 6000);
      expect(repo.movements, hasLength(2));
    },
  );

  test('reversal restores stock from the original movement', () async {
    final repo = FakeProductRepository(products: [sampleProduct()]);
    final received = await repo.recordMovement(
      ownerId: 'user-1',
      businessId: 'biz-1',
      productId: 'prod-1',
      draft: const StockMovementDraft(
        type: StockMovementType.received,
        quantityText: '2',
        unitCostText: '9.00',
        idempotencyKey: 'recv-rev',
      ),
    );
    await repo.recordMovement(
      ownerId: 'user-1',
      businessId: 'biz-1',
      productId: 'prod-1',
      draft: StockMovementDraft(
        type: StockMovementType.reversal,
        quantityText: '2',
        idempotencyKey: 'rev-1',
        reversesMovementId: received.id,
      ),
    );
    final product = await repo.findById(
      ownerId: 'user-1',
      businessId: 'biz-1',
      productId: 'prod-1',
    );
    expect(product!.stockQuantityMilli, 5000);
  });

  test('archive keeps historical movements', () async {
    final repo = FakeProductRepository(products: [sampleProduct()]);
    await repo.recordMovement(
      ownerId: 'user-1',
      businessId: 'biz-1',
      productId: 'prod-1',
      draft: const StockMovementDraft(
        type: StockMovementType.received,
        quantityText: '1',
        idempotencyKey: 'recv-keep',
      ),
    );
    await repo.archive(
      ownerId: 'user-1',
      businessId: 'biz-1',
      productId: 'prod-1',
    );
    expect(
      () => repo.delete(
        ownerId: 'user-1',
        businessId: 'biz-1',
        productId: 'prod-1',
      ),
      throwsA(isA<AuthFailure>()),
    );
    expect(repo.movements, isNotEmpty);
    expect(
      (await repo.findById(
        ownerId: 'user-1',
        businessId: 'biz-1',
        productId: 'prod-1',
      ))!.isActive,
      isFalse,
    );
  });
}
