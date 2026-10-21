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

  SyncCoordinator coordinator() {
    return SyncCoordinator(
      outbox: outbox,
      remoteTransactions: remoteTransactions,
      remoteObligations: remoteObligations,
      transactionCache: transactionCache,
      obligationCache: obligationCache,
      currentOwnerId: () => currentOwner,
      clock: () => now,
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
}
