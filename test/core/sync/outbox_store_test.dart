import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/ledger_entry.dart';
import 'package:kgwebo/core/persistence/kgwebo_database.dart';
import 'package:kgwebo/core/sync/outbox_models.dart';
import 'package:kgwebo/core/sync/outbox_store.dart';
import 'package:kgwebo/features/transactions/domain/payment_method.dart';
import 'package:kgwebo/features/transactions/domain/transaction_draft.dart';
import 'package:path/path.dart' as p;

void main() {
  late KgweboDatabase database;
  late OutboxStore store;
  var closeSharedDatabase = true;

  final draft = TransactionDraft(
    type: MoneyMovementType.sale,
    amountText: '50.00',
    occurredOn: DateTime(2026, 10, 21),
    category: 'goods',
    paymentMethod: PaymentMethod.cash,
    paymentStatus: PaymentStatus.paid,
    idempotencyKey: '11111111-1111-1111-1111-111111111111',
  );

  CreateTransactionPayload payload() {
    return CreateTransactionPayload.fromDraft(
      currencyCode: 'BWP',
      draft: draft,
    );
  }

  setUp(() {
    database = KgweboDatabase.memory();
    store = OutboxStore(database, idGenerator: () => 'op-1');
  });

  tearDown(() async {
    if (closeSharedDatabase) {
      await database.close();
    }
    closeSharedDatabase = true;
  });

  test('schema version includes the outbox', () {
    expect(database.schemaVersion, 6);
  });

  test(
    'enqueued operations survive a new store on the same database',
    () async {
      await store.enqueue(
        ownerId: 'user-1',
        businessId: 'biz-1',
        operationType: OutboxOperationTypes.createTransactionV1,
        payloadJson: payload().encode(),
        idempotencyKey: draft.idempotencyKey,
      );
      final reloaded = OutboxStore(database);
      final open = await reloaded.listOpen(
        ownerId: 'user-1',
        businessId: 'biz-1',
      );
      expect(open, hasLength(1));
      expect(open.single.state, OutboxState.pending);
      expect(open.single.idempotencyKey, draft.idempotencyKey);
    },
  );

  test('file database keeps the outbox after close and reopen', () async {
    closeSharedDatabase = false;
    await database.close();
    final file = File(
      p.join(
        Directory.systemTemp.path,
        'kgwebo-outbox-${DateTime.now().microsecondsSinceEpoch}.sqlite',
      ),
    );
    addTearDown(() {
      if (file.existsSync()) {
        file.deleteSync();
      }
    });
    final first = KgweboDatabase.forExecutor(NativeDatabase(file));
    final firstStore = OutboxStore(first, idGenerator: () => 'op-file');
    await firstStore.enqueue(
      ownerId: 'user-1',
      businessId: 'biz-1',
      operationType: OutboxOperationTypes.createTransactionV1,
      payloadJson: payload().encode(),
      idempotencyKey: draft.idempotencyKey,
    );
    await first.close();

    final second = KgweboDatabase.forExecutor(NativeDatabase(file));
    addTearDown(second.close);
    final loaded = await OutboxStore(
      second,
    ).listOpen(ownerId: 'user-1', businessId: 'biz-1');
    expect(loaded, hasLength(1));
    expect(loaded.single.operationId, 'op-file');
  });

  test(
    'duplicate enqueue with the same idempotency key returns one row',
    () async {
      final first = await store.enqueue(
        ownerId: 'user-1',
        businessId: 'biz-1',
        operationType: OutboxOperationTypes.createTransactionV1,
        payloadJson: payload().encode(),
        idempotencyKey: draft.idempotencyKey,
      );
      final second = await store.enqueue(
        ownerId: 'user-1',
        businessId: 'biz-1',
        operationType: OutboxOperationTypes.createTransactionV1,
        payloadJson: payload().encode(),
        idempotencyKey: draft.idempotencyKey,
        operationId: 'op-2',
      );
      expect(second.operationId, first.operationId);
      final open = await store.listOpen(ownerId: 'user-1', businessId: 'biz-1');
      expect(open, hasLength(1));
    },
  );

  test('queries are owner and business scoped', () async {
    await store.enqueue(
      ownerId: 'user-1',
      businessId: 'biz-1',
      operationType: OutboxOperationTypes.createTransactionV1,
      payloadJson: payload().encode(),
      idempotencyKey: draft.idempotencyKey,
    );
    expect(
      await store.listOpen(ownerId: 'user-2', businessId: 'biz-1'),
      isEmpty,
    );
    expect(
      await store.listOpen(ownerId: 'user-1', businessId: 'biz-2'),
      isEmpty,
    );
  });

  test('recoverInterrupted returns syncing rows to pending', () async {
    await store.enqueue(
      ownerId: 'user-1',
      businessId: 'biz-1',
      operationType: OutboxOperationTypes.createTransactionV1,
      payloadJson: payload().encode(),
      idempotencyKey: draft.idempotencyKey,
    );
    await store.markSyncing('op-1', DateTime.utc(2026, 10, 21, 12));
    await store.recoverInterrupted();
    final open = await store.listOpen(ownerId: 'user-1', businessId: 'biz-1');
    expect(open.single.state, OutboxState.pending);
    expect(open.single.lastErrorCode, 'interrupted');
  });

  test('automatic retries pause after the attempt cap', () async {
    await store.enqueue(
      ownerId: 'user-1',
      businessId: 'biz-1',
      operationType: OutboxOperationTypes.createTransactionV1,
      payloadJson: payload().encode(),
      idempotencyKey: draft.idempotencyKey,
    );
    await store.markRetryable(
      operationId: 'op-1',
      error: Exception('network'),
      now: DateTime.utc(2026, 10, 21, 12),
      attemptCount: SyncPolicy.maxAutomaticAttempts,
    );
    final due = await store.listDue(
      ownerId: 'user-1',
      businessId: 'biz-1',
      now: DateTime.utc(2026, 10, 22),
    );
    expect(due, isEmpty);
    final open = await store.listOpen(ownerId: 'user-1', businessId: 'biz-1');
    expect(open.single.state, OutboxState.retryableFailure);
    await store.requestManualRetry('op-1', DateTime.utc(2026, 10, 22));
    final afterRetry = await store.listDue(
      ownerId: 'user-1',
      businessId: 'biz-1',
      now: DateTime.utc(2026, 10, 22),
    );
    expect(afterRetry, hasLength(1));
    expect(afterRetry.single.state, OutboxState.pending);
  });
}
