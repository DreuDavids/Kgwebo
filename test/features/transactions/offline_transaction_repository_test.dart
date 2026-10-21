import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/ledger_entry.dart';
import 'package:kgwebo/core/persistence/kgwebo_database.dart';
import 'package:kgwebo/core/persistence/transaction_cache.dart';
import 'package:kgwebo/core/sync/outbox_store.dart';
import 'package:kgwebo/core/sync/pending_presentation.dart';
import 'package:kgwebo/features/authentication/domain/auth_failure.dart';
import 'package:kgwebo/features/transactions/data/cached_transaction_repository.dart';
import 'package:kgwebo/features/transactions/domain/payment_method.dart';
import 'package:kgwebo/features/transactions/domain/transaction_draft.dart';

import '../../helpers/fake_transactions.dart';

void main() {
  late FakeTransactionRepository remote;
  late KgweboDatabase database;
  late OutboxStore outbox;
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
    outbox = OutboxStore(database, idGenerator: () => 'op-offline');
    repository = CachedTransactionRepository(
      remote: remote,
      cache: TransactionCache(database),
      currentOwnerId: () => 'user-1',
      outbox: outbox,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('queues a create on a retryable network failure', () async {
    remote.nextError = const AuthFailure.network();
    final saved = await repository.create(
      ownerId: 'user-1',
      businessId: 'biz-1',
      currencyCode: 'BWP',
      draft: draft,
    );
    expect(saved.pendingSync, isTrue);
    expect(saved.id, 'pending:op-offline');
    final confirmed = await TransactionCache(
      database,
    ).listConfirmed(ownerId: 'user-1', businessId: 'biz-1');
    expect(confirmed, isEmpty);
    final queued = await outbox.listOpen(
      ownerId: 'user-1',
      businessId: 'biz-1',
    );
    expect(queued, hasLength(1));
    expect(queued.single.idempotencyKey, draft.idempotencyKey);
  });

  test('does not queue a second row for the same idempotency key', () async {
    remote.nextError = const AuthFailure.network();
    await repository.create(
      ownerId: 'user-1',
      businessId: 'biz-1',
      currencyCode: 'BWP',
      draft: draft,
    );
    remote.nextError = const AuthFailure.network();
    await repository.create(
      ownerId: 'user-1',
      businessId: 'biz-1',
      currencyCode: 'BWP',
      draft: draft,
    );
    final queued = await outbox.listOpen(
      ownerId: 'user-1',
      businessId: 'biz-1',
    );
    expect(queued, hasLength(1));
  });

  test('reconciles a queued row when the server copy later appears', () async {
    remote.nextError = const AuthFailure.network();
    await repository.create(
      ownerId: 'user-1',
      businessId: 'biz-1',
      currencyCode: 'BWP',
      draft: draft,
    );
    await remote.create(
      ownerId: 'user-1',
      businessId: 'biz-1',
      currencyCode: 'BWP',
      draft: draft,
    );
    final listed = await repository.list(
      ownerId: 'user-1',
      businessId: 'biz-1',
    );
    expect(listed.items, hasLength(1));
    expect(listed.items.single.pendingSync, isFalse);
    final queued = await outbox.listOpen(
      ownerId: 'user-1',
      businessId: 'biz-1',
    );
    expect(queued, isEmpty);
    final merged = mergePendingTransactions(
      confirmed: listed.items,
      operations: await outbox.listForOwner('user-1'),
    );
    expect(merged, hasLength(1));
  });

  test('permanent failures still throw and do not enqueue', () async {
    remote.nextError = const AuthFailure(
      'This business does not belong to the signed-in account.',
    );
    expect(
      () => repository.create(
        ownerId: 'user-1',
        businessId: 'biz-1',
        currencyCode: 'BWP',
        draft: draft,
      ),
      throwsA(isA<AuthFailure>()),
    );
    expect(
      await outbox.listOpen(ownerId: 'user-1', businessId: 'biz-1'),
      isEmpty,
    );
  });

  test('owner mismatch does not enqueue another account\'s write', () async {
    remote.nextError = const AuthFailure.network();
    expect(
      () => repository.create(
        ownerId: 'user-2',
        businessId: 'biz-2',
        currencyCode: 'BWP',
        draft: draft,
      ),
      throwsA(isA<AuthFailure>()),
    );
    expect(await outbox.listForOwner('user-2'), isEmpty);
    expect(await outbox.listForOwner('user-1'), isEmpty);
  });
}
