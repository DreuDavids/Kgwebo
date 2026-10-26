import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/cash_outlook.dart';
import 'package:kgwebo/core/finance/ledger_entry.dart';
import 'package:kgwebo/core/persistence/kgwebo_database.dart';
import 'package:kgwebo/core/persistence/obligation_cache.dart';
import 'package:kgwebo/core/persistence/transaction_cache.dart';
import 'package:kgwebo/core/sync/outbox_models.dart';
import 'package:kgwebo/core/sync/outbox_store.dart';
import 'package:kgwebo/core/sync/sync_coordinator.dart';
import 'package:kgwebo/features/authentication/domain/auth_failure.dart';
import 'package:kgwebo/features/obligations/domain/obligation_draft.dart';
import 'package:kgwebo/features/transactions/domain/payment_method.dart';
import 'package:kgwebo/features/transactions/domain/transaction_draft.dart';

import '../../helpers/fake_obligations.dart';
import '../../helpers/fake_transactions.dart';

void main() {
  late KgweboDatabase database;
  late OutboxStore outbox;
  late FakeTransactionRepository remoteTransactions;
  late FakeObligationRepository remoteObligations;
  late TransactionCache transactionCache;
  late ObligationCache obligationCache;
  late DateTime now;
  String? currentOwner = 'user-1';
  String? currentBusiness = 'biz-1';

  final saleDraft = TransactionDraft(
    type: MoneyMovementType.sale,
    amountText: '50.00',
    occurredOn: DateTime(2026, 10, 21),
    category: 'goods',
    paymentMethod: PaymentMethod.cash,
    paymentStatus: PaymentStatus.paid,
    idempotencyKey: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  );

  final billDraft = ObligationDraft(
    title: 'Rent',
    amountText: '80.00',
    dueOn: DateTime(2026, 11, 1),
    category: 'rent',
    status: CommitmentStatus.unpaid,
    idempotencyKey: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  );

  SyncCoordinator coordinator({Duration? dispatchTimeout}) {
    return SyncCoordinator(
      outbox: outbox,
      remoteTransactions: remoteTransactions,
      remoteObligations: remoteObligations,
      transactionCache: transactionCache,
      obligationCache: obligationCache,
      currentOwnerId: () => currentOwner,
      currentBusinessId: () => currentBusiness,
      clock: () => now,
      dispatchTimeout: dispatchTimeout,
    );
  }

  Future<OutboxOperation> enqueueSale({
    String ownerId = 'user-1',
    String operationId = 'op-sale',
    String? dependsOn,
  }) {
    final payload = CreateTransactionPayload.fromDraft(
      currencyCode: 'BWP',
      draft: saleDraft,
    );
    return outbox.enqueue(
      ownerId: ownerId,
      businessId: 'biz-1',
      operationType: OutboxOperationTypes.createTransactionV1,
      payloadJson: payload.encode(),
      idempotencyKey: saleDraft.idempotencyKey,
      operationId: operationId,
      createdAt: now,
      dependsOnOperationId: dependsOn,
    );
  }

  setUp(() {
    database = KgweboDatabase.memory();
    outbox = OutboxStore(database);
    remoteTransactions = FakeTransactionRepository();
    remoteObligations = FakeObligationRepository();
    transactionCache = TransactionCache(database);
    obligationCache = ObligationCache(database);
    now = DateTime.utc(2026, 10, 21, 12);
    currentOwner = 'user-1';
    currentBusiness = 'biz-1';
  });

  tearDown(() async {
    await database.close();
  });

  test('processes due operations in created order', () async {
    final laterDraft = TransactionDraft(
      type: MoneyMovementType.expense,
      amountText: '10.00',
      occurredOn: DateTime(2026, 10, 21),
      category: 'rent',
      paymentMethod: PaymentMethod.cash,
      paymentStatus: PaymentStatus.paid,
      idempotencyKey: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
    );
    await outbox.enqueue(
      ownerId: 'user-1',
      businessId: 'biz-1',
      operationType: OutboxOperationTypes.createTransactionV1,
      payloadJson:
          CreateTransactionPayload.fromDraft(
            currencyCode: 'BWP',
            draft: saleDraft,
          ).encode(),
      idempotencyKey: saleDraft.idempotencyKey,
      operationId: 'op-1',
      createdAt: now,
    );
    await outbox.enqueue(
      ownerId: 'user-1',
      businessId: 'biz-1',
      operationType: OutboxOperationTypes.createTransactionV1,
      payloadJson:
          CreateTransactionPayload.fromDraft(
            currencyCode: 'BWP',
            draft: laterDraft,
          ).encode(),
      idempotencyKey: laterDraft.idempotencyKey,
      operationId: 'op-2',
      createdAt: now.add(const Duration(seconds: 1)),
    );
    final result = await coordinator().process(
      ownerId: 'user-1',
      businessId: 'biz-1',
    );
    expect(result.succeeded, 2);
    expect(remoteTransactions.createCalls, 2);
    expect(remoteTransactions.items.map((item) => item.type), [
      MoneyMovementType.sale,
      MoneyMovementType.expense,
    ]);
  });

  test(
    'waits for a dependency before submitting the later operation',
    () async {
      await outbox.enqueue(
        ownerId: 'user-1',
        businessId: 'biz-1',
        operationType: OutboxOperationTypes.createObligationV1,
        payloadJson:
            CreateObligationPayload.fromDraft(
              currencyCode: 'BWP',
              draft: billDraft,
            ).encode(),
        idempotencyKey: billDraft.idempotencyKey,
        operationId: 'op-bill',
        createdAt: now,
      );
      await enqueueSale(operationId: 'op-sale', dependsOn: 'op-missing');
      remoteObligations.nextError = const AuthFailure(
        'This commitment could not be validated.',
      );
      final result = await coordinator().process(
        ownerId: 'user-1',
        businessId: 'biz-1',
      );
      expect(result.permanent, 1);
      expect(remoteTransactions.createCalls, 0);
      final open = await outbox.listOpen(
        ownerId: 'user-1',
        businessId: 'biz-1',
      );
      expect(
        open.where((item) => item.operationId == 'op-sale').single.state,
        OutboxState.pending,
      );
    },
  );

  test('retries with the original idempotency key after a timeout', () async {
    remoteTransactions.failAfterCreate = const AuthFailure.network();
    await enqueueSale();
    final first = await coordinator().process(
      ownerId: 'user-1',
      businessId: 'biz-1',
    );
    expect(first.retryable, 1);
    expect(remoteTransactions.items, hasLength(1));
    now = now.add(const Duration(minutes: 1));
    final second = await coordinator().process(
      ownerId: 'user-1',
      businessId: 'biz-1',
    );
    expect(second.succeeded, 1);
    expect(remoteTransactions.createCalls, 2);
    expect(remoteTransactions.items, hasLength(1));
    final cached = await transactionCache.listConfirmed(
      ownerId: 'user-1',
      businessId: 'biz-1',
    );
    expect(cached, hasLength(1));
    expect(cached.single.idempotencyKey, saleDraft.idempotencyKey);
  });

  test('network loss before commit leaves a retryable operation', () async {
    remoteTransactions.nextError = const AuthFailure.network();
    await enqueueSale();
    final first = await coordinator().process(
      ownerId: 'user-1',
      businessId: 'biz-1',
    );
    expect(first.retryable, 1);
    expect(remoteTransactions.items, isEmpty);
    now = now.add(const Duration(minutes: 1));
    final second = await coordinator().process(
      ownerId: 'user-1',
      businessId: 'biz-1',
    );
    expect(second.succeeded, 1);
    expect(remoteTransactions.items, hasLength(1));
  });

  test('permanent validation failures are quarantined', () async {
    remoteTransactions.nextError = const AuthFailure(
      'The amount is not valid.',
    );
    await enqueueSale();
    final result = await coordinator().process(
      ownerId: 'user-1',
      businessId: 'biz-1',
    );
    expect(result.permanent, 1);
    final open = await outbox.listOpen(ownerId: 'user-1', businessId: 'biz-1');
    expect(open.single.state, OutboxState.permanentFailure);
    expect(open.single.lastErrorMessage, contains('not valid'));
  });

  test('does not submit another owner\'s queued operations', () async {
    await enqueueSale(ownerId: 'user-1');
    currentOwner = 'user-2';
    final result = await coordinator().process(
      ownerId: 'user-1',
      businessId: 'biz-1',
    );
    expect(result.skipped, isTrue);
    expect(remoteTransactions.createCalls, 0);
    currentOwner = null;
    final signedOut = await coordinator().process(
      ownerId: 'user-1',
      businessId: 'biz-1',
    );
    expect(signedOut.skipped, isTrue);
    expect(remoteTransactions.createCalls, 0);
    final stillQueued = await outbox.listOpen(
      ownerId: 'user-1',
      businessId: 'biz-1',
    );
    expect(stillQueued, hasLength(1));
  });

  test(
    'overlapping process calls do not submit the same operation twice',
    () async {
      remoteTransactions.createDelay = const Duration(milliseconds: 40);
      await enqueueSale();
      final coord = coordinator();
      final first = coord.process(ownerId: 'user-1', businessId: 'biz-1');
      final second = coord.process(ownerId: 'user-1', businessId: 'biz-1');
      expect((await second).alreadyRunning, isTrue);
      expect((await first).succeeded, 1);
      expect(remoteTransactions.createCalls, 1);
    },
  );

  test('recovers interrupted syncing rows before submitting', () async {
    await enqueueSale();
    await outbox.markSyncing(
      operationId: 'op-sale',
      ownerId: 'user-1',
      businessId: 'biz-1',
      now: now,
    );
    final result = await coordinator().process(
      ownerId: 'user-1',
      businessId: 'biz-1',
    );
    expect(result.succeeded, 1);
    expect(remoteTransactions.createCalls, 1);
  });

  test('paused automatic retries wait for a manual retry', () async {
    await enqueueSale();
    await outbox.markRetryable(
      operationId: 'op-sale',
      ownerId: 'user-1',
      businessId: 'biz-1',
      error: const AuthFailure.network(),
      now: now,
      attemptCount: SyncPolicy.maxAutomaticAttempts,
    );
    final paused = await coordinator().process(
      ownerId: 'user-1',
      businessId: 'biz-1',
    );
    expect(paused.processed, 0);
    expect(remoteTransactions.createCalls, 0);
    await coordinator().retry('op-sale');
    final after = await coordinator().process(
      ownerId: 'user-1',
      businessId: 'biz-1',
    );
    expect(after.succeeded, 1);
    expect(remoteTransactions.createCalls, 1);
  });

  test('malformed payloads are quarantined instead of retried', () async {
    await outbox.enqueue(
      ownerId: 'user-1',
      businessId: 'biz-1',
      operationType: OutboxOperationTypes.createTransactionV1,
      payloadJson: '{not-json',
      idempotencyKey: 'dddddddd-dddd-dddd-dddd-dddddddddddd',
      operationId: 'op-bad',
      createdAt: now,
    );
    final result = await coordinator().process(
      ownerId: 'user-1',
      businessId: 'biz-1',
    );
    expect(result.permanent, 1);
    expect(remoteTransactions.createCalls, 0);
    final open = await outbox.listOpen(ownerId: 'user-1', businessId: 'biz-1');
    expect(open.single.state, OutboxState.permanentFailure);
  });

  test(
    'does not submit an operation already reconciled as succeeded',
    () async {
      await enqueueSale();
      await outbox.markSucceeded(
        operationId: 'op-sale',
        ownerId: 'user-1',
        businessId: 'biz-1',
        now: now,
      );
      await outbox.markRetryable(
        operationId: 'op-sale',
        ownerId: 'user-1',
        businessId: 'biz-1',
        error: const AuthFailure.network(),
        now: now,
        attemptCount: 1,
      );
      final result = await coordinator().process(
        ownerId: 'user-1',
        businessId: 'biz-1',
      );
      expect(result.processed, 0);
      expect(remoteTransactions.createCalls, 0);
      expect(
        await outbox.listOpen(ownerId: 'user-1', businessId: 'biz-1'),
        isEmpty,
      );
    },
  );

  test(
    'owner change during an in-flight request does not mark the op permanent',
    () async {
      final gate = remoteTransactions.armCreateGate();
      remoteTransactions.nextError = const AuthFailure(
        'This transaction does not belong to the signed-in account.',
      );
      await enqueueSale();
      final coord = coordinator();
      final inFlight = coord.process(ownerId: 'user-1', businessId: 'biz-1');
      await remoteTransactions.enteredCreate;
      currentOwner = 'user-2';
      gate.complete();
      final result = await inFlight;
      expect(result.permanent, 0);
      expect(remoteTransactions.createCalls, 1);
      final open = await outbox.listOpen(
        ownerId: 'user-1',
        businessId: 'biz-1',
      );
      expect(open, hasLength(1));
      expect(open.single.state, isNot(OutboxState.permanentFailure));
      expect(open.single.state, isNot(OutboxState.succeeded));
    },
  );

  test(
    'overlapping process after an owner change still runs the new owner',
    () async {
      remoteTransactions.allowAnyOwner = true;
      final laterDraft = TransactionDraft(
        type: MoneyMovementType.expense,
        amountText: '12.00',
        occurredOn: DateTime(2026, 10, 21),
        category: 'rent',
        paymentMethod: PaymentMethod.cash,
        paymentStatus: PaymentStatus.paid,
        idempotencyKey: 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
      );
      await enqueueSale(ownerId: 'user-1', operationId: 'op-sale');
      await outbox.enqueue(
        ownerId: 'user-2',
        businessId: 'biz-2',
        operationType: OutboxOperationTypes.createTransactionV1,
        payloadJson:
            CreateTransactionPayload.fromDraft(
              currencyCode: 'BWP',
              draft: laterDraft,
            ).encode(),
        idempotencyKey: laterDraft.idempotencyKey,
        operationId: 'op-user-2',
        createdAt: now,
      );
      final gate = remoteTransactions.armCreateGate();
      final coord = coordinator();
      final first = coord.process(ownerId: 'user-1', businessId: 'biz-1');
      await remoteTransactions.enteredCreate;
      currentOwner = 'user-2';
      currentBusiness = 'biz-2';
      final second = coord.process(ownerId: 'user-2', businessId: 'biz-2');
      expect((await second).alreadyRunning, isTrue);
      gate.complete();
      await first;
      final user2 = await outbox.listOpen(
        ownerId: 'user-2',
        businessId: 'biz-2',
      );
      expect(user2.where((item) => item.state == OutboxState.pending), isEmpty);
      expect(
        remoteTransactions.items.where((item) => item.ownerId == 'user-2'),
        hasLength(1),
      );
    },
  );

  test(
    'manual retry from another account leaves the original op paused',
    () async {
      await enqueueSale();
      await outbox.markRetryable(
        operationId: 'op-sale',
        ownerId: 'user-1',
        businessId: 'biz-1',
        error: const AuthFailure.network(),
        now: now,
        attemptCount: SyncPolicy.maxAutomaticAttempts,
      );
      currentOwner = 'user-2';
      await coordinator().retry('op-sale');
      final open = await outbox.listOpen(
        ownerId: 'user-1',
        businessId: 'biz-1',
      );
      expect(open.single.state, OutboxState.retryableFailure);
      expect(open.single.nextAttemptAt, isNull);
      expect(remoteTransactions.createCalls, 0);
    },
  );

  test(
    'two coordinators cannot submit the same operation concurrently',
    () async {
      final gate = remoteTransactions.armCreateGate();
      final secondEntered = Completer<void>();
      remoteTransactions.onCreateEntered = (count) {
        if (count >= 2 && !secondEntered.isCompleted) {
          secondEntered.complete();
        }
      };
      await enqueueSale();
      final first = coordinator();
      final second = coordinator();
      final left = first.process(ownerId: 'user-1', businessId: 'biz-1');
      await remoteTransactions.enteredCreate;
      final right = second.process(ownerId: 'user-1', businessId: 'biz-1');
      await Future.any<void>([secondEntered.future, right]);
      if (!gate.isCompleted) {
        gate.complete();
      }
      await Future.wait([left, right]);
      expect(remoteTransactions.createCalls, 1);
      expect(remoteTransactions.items, hasLength(1));
    },
  );

  test(
    'late success after an owner switch records the original owner only',
    () async {
      remoteTransactions.allowAnyOwner = true;
      final gate = remoteTransactions.armCreateGate();
      await enqueueSale();
      await outbox.enqueue(
        ownerId: 'user-2',
        businessId: 'biz-2',
        operationType: OutboxOperationTypes.createTransactionV1,
        payloadJson:
            CreateTransactionPayload.fromDraft(
              currencyCode: 'BWP',
              draft: billDraftToSale(),
            ).encode(),
        idempotencyKey: 'ffffffff-ffff-ffff-ffff-ffffffffffff',
        operationId: 'op-user-2',
        createdAt: now,
      );
      final coord = coordinator();
      final inFlight = coord.process(ownerId: 'user-1', businessId: 'biz-1');
      await remoteTransactions.enteredCreate;
      currentOwner = 'user-2';
      gate.complete();
      await inFlight;
      expect(
        await outbox.listOpen(ownerId: 'user-1', businessId: 'biz-1'),
        isEmpty,
      );
      final user2 = await outbox.listOpen(
        ownerId: 'user-2',
        businessId: 'biz-2',
      );
      expect(user2, hasLength(1));
      expect(user2.single.state, isNot(OutboxState.succeeded));
      expect(remoteTransactions.items.map((item) => item.ownerId), ['user-1']);
      final cached = await transactionCache.listConfirmed(
        ownerId: 'user-1',
        businessId: 'biz-1',
      );
      expect(cached, hasLength(1));
      expect(
        await transactionCache.listConfirmed(
          ownerId: 'user-2',
          businessId: 'biz-2',
        ),
        isEmpty,
      );
    },
  );

  test('a third overlapping process does not drop a queued owner', () async {
    remoteTransactions.allowAnyOwner = true;
    final laterDraft = TransactionDraft(
      type: MoneyMovementType.expense,
      amountText: '12.00',
      occurredOn: DateTime(2026, 10, 21),
      category: 'rent',
      paymentMethod: PaymentMethod.cash,
      paymentStatus: PaymentStatus.paid,
      idempotencyKey: 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
    );
    await enqueueSale(ownerId: 'user-1', operationId: 'op-sale');
    await outbox.enqueue(
      ownerId: 'user-2',
      businessId: 'biz-2',
      operationType: OutboxOperationTypes.createTransactionV1,
      payloadJson:
          CreateTransactionPayload.fromDraft(
            currencyCode: 'BWP',
            draft: laterDraft,
          ).encode(),
      idempotencyKey: laterDraft.idempotencyKey,
      operationId: 'op-user-2',
      createdAt: now,
    );
    final gate = remoteTransactions.armCreateGate();
    final coord = coordinator();
    final first = coord.process(ownerId: 'user-1', businessId: 'biz-1');
    await remoteTransactions.enteredCreate;
    currentOwner = 'user-2';
    currentBusiness = 'biz-2';
    final second = coord.process(ownerId: 'user-2', businessId: 'biz-2');
    expect((await second).alreadyRunning, isTrue);
    final third = coord.process(ownerId: 'user-1', businessId: 'biz-1');
    expect((await third).alreadyRunning, isTrue);
    gate.complete();
    await first;
    final user2 = await outbox.listOpen(ownerId: 'user-2', businessId: 'biz-2');
    expect(user2.where((item) => item.state == OutboxState.pending), isEmpty);
    expect(
      remoteTransactions.items.where((item) => item.ownerId == 'user-2'),
      hasLength(1),
    );
  });

  test(
    'a hung dispatch is marked retryable instead of permanent or stuck syncing',
    () async {
      final gate = remoteTransactions.armCreateGate();
      addTearDown(() {
        if (!gate.isCompleted) {
          gate.complete();
        }
      });
      await enqueueSale();
      final result = await coordinator(
        dispatchTimeout: const Duration(milliseconds: 20),
      ).process(ownerId: 'user-1', businessId: 'biz-1');
      expect(result.permanent, 0);
      expect(result.retryable, 1);
      final open = await outbox.listOpen(
        ownerId: 'user-1',
        businessId: 'biz-1',
      );
      expect(open, hasLength(1));
      expect(open.single.state, OutboxState.retryableFailure);
      expect(open.single.state, isNot(OutboxState.syncing));
      expect(open.single.state, isNot(OutboxState.permanentFailure));
    },
  );
}

TransactionDraft billDraftToSale() {
  return TransactionDraft(
    type: MoneyMovementType.sale,
    amountText: '9.00',
    occurredOn: DateTime(2026, 10, 21),
    category: 'goods',
    paymentMethod: PaymentMethod.cash,
    paymentStatus: PaymentStatus.paid,
    idempotencyKey: 'ffffffff-ffff-ffff-ffff-ffffffffffff',
  );
}
