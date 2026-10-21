import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/ledger_entry.dart';
import 'package:kgwebo/core/persistence/kgwebo_database.dart';
import 'package:kgwebo/core/persistence/transaction_cache.dart';
import 'package:kgwebo/features/authentication/domain/auth_failure.dart';
import 'package:kgwebo/features/transactions/data/cached_transaction_repository.dart';
import 'package:kgwebo/features/transactions/domain/payment_method.dart';
import 'package:kgwebo/features/transactions/domain/transaction_draft.dart';

import '../../helpers/fake_transactions.dart';

void main() {
  late FakeTransactionRepository remote;
  late KgweboDatabase database;
  late CachedTransactionRepository repository;

  final draft = TransactionDraft(
    type: MoneyMovementType.sale,
    amountText: '500.00',
    occurredOn: DateTime(2026, 10, 10),
    category: 'goods',
    paymentMethod: PaymentMethod.cash,
    paymentStatus: PaymentStatus.paid,
    idempotencyKey: '11111111-1111-1111-1111-111111111111',
  );

  setUp(() {
    remote = FakeTransactionRepository();
    database = KgweboDatabase.memory();
    repository = CachedTransactionRepository(
      remote: remote,
      cache: TransactionCache(database),
      currentOwnerId: () => 'user-1',
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('create sale persists once and is readable from cache', () async {
    final saved = await repository.create(
      ownerId: 'user-1',
      businessId: 'biz-1',
      currencyCode: 'BWP',
      draft: draft,
    );
    expect(saved.amountMinor, 50000);
    expect(saved.type, MoneyMovementType.sale);
    final listed = await repository.list(
      ownerId: 'user-1',
      businessId: 'biz-1',
    );
    expect(listed.items, hasLength(1));
    expect(listed.items.single.id, saved.id);
  });

  test('create expense is a separate type', () async {
    final saved = await repository.create(
      ownerId: 'user-1',
      businessId: 'biz-1',
      currencyCode: 'BWP',
      draft: TransactionDraft(
        type: MoneyMovementType.expense,
        amountText: '100.00',
        occurredOn: DateTime(2026, 10, 11),
        category: 'rent',
        paymentMethod: PaymentMethod.cash,
        paymentStatus: PaymentStatus.paid,
        idempotencyKey: '22222222-2222-2222-2222-222222222222',
      ),
    );
    expect(saved.type, MoneyMovementType.expense);
    expect(saved.amountMinor, 10000);
  });

  test('duplicate idempotency key does not insert a second row', () async {
    final first = await repository.create(
      ownerId: 'user-1',
      businessId: 'biz-1',
      currencyCode: 'BWP',
      draft: draft,
    );
    final second = await repository.create(
      ownerId: 'user-1',
      businessId: 'biz-1',
      currencyCode: 'BWP',
      draft: draft,
    );
    expect(second.id, first.id);
    expect(remote.items, hasLength(1));
    expect(remote.createCalls, 2);
  });

  test('update keeps the same id', () async {
    final created = await repository.create(
      ownerId: 'user-1',
      businessId: 'biz-1',
      currencyCode: 'BWP',
      draft: draft,
    );
    final updated = await repository.update(
      ownerId: 'user-1',
      businessId: 'biz-1',
      currencyCode: 'BWP',
      draft: TransactionDraft(
        type: MoneyMovementType.sale,
        amountText: '600.00',
        occurredOn: DateTime(2026, 10, 10),
        category: 'goods',
        paymentMethod: PaymentMethod.cash,
        paymentStatus: PaymentStatus.paid,
        idempotencyKey: draft.idempotencyKey,
        existingId: created.id,
      ),
    );
    expect(updated.id, created.id);
    expect(updated.amountMinor, 60000);
    expect(remote.items, hasLength(1));
  });

  test('delete removes the row', () async {
    final created = await repository.create(
      ownerId: 'user-1',
      businessId: 'biz-1',
      currencyCode: 'BWP',
      draft: draft,
    );
    await repository.delete(
      ownerId: 'user-1',
      businessId: 'biz-1',
      transactionId: created.id,
    );
    final listed = await repository.list(
      ownerId: 'user-1',
      businessId: 'biz-1',
    );
    expect(listed.items, isEmpty);
  });

  test('invalid amounts are rejected before a write', () async {
    expect(
      () => repository.create(
        ownerId: 'user-1',
        businessId: 'biz-1',
        currencyCode: 'BWP',
        draft: TransactionDraft(
          type: MoneyMovementType.sale,
          amountText: '0',
          occurredOn: DateTime(2026, 10, 10),
          category: 'goods',
          paymentMethod: PaymentMethod.cash,
          paymentStatus: PaymentStatus.paid,
          idempotencyKey: '33333333-3333-3333-3333-333333333333',
        ),
      ),
      throwsA(isA<FormatException>()),
    );
    expect(remote.items, isEmpty);
  });

  test('retryable list failure keeps confirmed cache', () async {
    await repository.create(
      ownerId: 'user-1',
      businessId: 'biz-1',
      currencyCode: 'BWP',
      draft: draft,
    );
    remote.nextError = const AuthFailure.network();
    final snapshot = await repository.list(
      ownerId: 'user-1',
      businessId: 'biz-1',
    );
    expect(snapshot.isStale, isTrue);
    expect(snapshot.items, hasLength(1));
  });

  test('ambiguous create then retry reuses the same key', () async {
    remote.failAfterCreate = const AuthFailure.network();
    expect(
      () => repository.create(
        ownerId: 'user-1',
        businessId: 'biz-1',
        currencyCode: 'BWP',
        draft: draft,
      ),
      throwsA(isA<AuthFailure>()),
    );
    expect(remote.items, hasLength(1));
    final saved = await repository.create(
      ownerId: 'user-1',
      businessId: 'biz-1',
      currencyCode: 'BWP',
      draft: draft,
    );
    expect(remote.items, hasLength(1));
    expect(saved.id, remote.items.single.id);
  });

  test('another owner cannot read or write this business', () async {
    await repository.create(
      ownerId: 'user-1',
      businessId: 'biz-1',
      currencyCode: 'BWP',
      draft: draft,
    );
    expect(
      () => repository.list(ownerId: 'user-b', businessId: 'biz-1'),
      throwsA(isA<AuthFailure>()),
    );
    expect(
      () => repository.create(
        ownerId: 'user-b',
        businessId: 'biz-1',
        currencyCode: 'BWP',
        draft: draft,
      ),
      throwsA(isA<AuthFailure>()),
    );
  });
}
