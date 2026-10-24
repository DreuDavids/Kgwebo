import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/cash_outlook.dart';
import 'package:kgwebo/core/persistence/kgwebo_database.dart';
import 'package:kgwebo/core/persistence/obligation_cache.dart';
import 'package:kgwebo/core/sync/outbox_store.dart';
import 'package:kgwebo/features/authentication/domain/auth_failure.dart';
import 'package:kgwebo/features/obligations/data/cached_obligation_repository.dart';
import 'package:kgwebo/features/obligations/domain/obligation_draft.dart';

import '../../helpers/fake_obligations.dart';

void main() {
  late FakeObligationRepository remote;
  late KgweboDatabase database;
  late OutboxStore outbox;
  late CachedObligationRepository repository;

  ObligationDraft draft({
    CommitmentStatus status = CommitmentStatus.unpaid,
    String key = '22222222-2222-2222-2222-222222222222',
  }) {
    return ObligationDraft(
      title: 'Shop rent',
      amountText: '80.00',
      dueOn: DateTime(2026, 11, 1),
      category: 'rent',
      status: status,
      idempotencyKey: key,
    );
  }

  setUp(() {
    remote = FakeObligationRepository();
    database = KgweboDatabase.memory();
    outbox = OutboxStore(database, idGenerator: () => 'op-bill');
    repository = CachedObligationRepository(
      remote: remote,
      cache: ObligationCache(database),
      currentOwnerId: () => 'user-1',
      outbox: outbox,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('queues an unpaid create on a retryable network failure', () async {
    remote.nextError = const AuthFailure.network();
    final saved = await repository.create(
      ownerId: 'user-1',
      businessId: 'biz-1',
      currencyCode: 'BWP',
      draft: draft(),
    );
    expect(saved.pendingSync, isTrue);
    expect(
      await ObligationCache(
        database,
      ).listConfirmed(ownerId: 'user-1', businessId: 'biz-1'),
      isEmpty,
    );
    final queued = await outbox.listOpen(
      ownerId: 'user-1',
      businessId: 'biz-1',
    );
    expect(queued, hasLength(1));
    expect(queued.single.idempotencyKey, draft().idempotencyKey);
  });

  test('does not queue paid or cancelled commitment creates', () async {
    for (final status in [CommitmentStatus.paid, CommitmentStatus.cancelled]) {
      remote.nextError = const AuthFailure.network();
      expect(
        () => repository.create(
          ownerId: 'user-1',
          businessId: 'biz-1',
          currencyCode: 'BWP',
          draft: draft(status: status, key: 'key-$status'),
        ),
        throwsA(isA<AuthFailure>()),
      );
    }
    expect(
      await outbox.listOpen(ownerId: 'user-1', businessId: 'biz-1'),
      isEmpty,
    );
  });
}
