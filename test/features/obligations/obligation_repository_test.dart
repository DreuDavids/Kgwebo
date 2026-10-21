import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/cash_outlook.dart';
import 'package:kgwebo/core/persistence/kgwebo_database.dart';
import 'package:kgwebo/core/persistence/obligation_cache.dart';
import 'package:kgwebo/features/authentication/domain/auth_failure.dart';
import 'package:kgwebo/features/obligations/data/cached_obligation_repository.dart';
import 'package:kgwebo/features/obligations/domain/obligation_draft.dart';

import '../../helpers/fake_obligations.dart';

void main() {
  late FakeObligationRepository remote;
  late KgweboDatabase database;
  late CachedObligationRepository repository;

  final draft = ObligationDraft(
    title: 'Shop rent',
    amountText: '800.00',
    dueOn: DateTime(2026, 10, 28),
    category: 'rent',
    status: CommitmentStatus.unpaid,
    idempotencyKey: '11111111-1111-1111-1111-111111111111',
  );

  setUp(() {
    remote = FakeObligationRepository();
    database = KgweboDatabase.memory();
    repository = CachedObligationRepository(
      remote: remote,
      cache: ObligationCache(database),
      currentOwnerId: () => 'user-1',
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('create persists once and is readable from cache', () async {
    final saved = await repository.create(
      ownerId: 'user-1',
      businessId: 'biz-1',
      currencyCode: 'BWP',
      draft: draft,
    );
    expect(saved.amountMinor, 80000);
    expect(saved.status, CommitmentStatus.unpaid);
    final listed = await repository.listAllConfirmed(
      ownerId: 'user-1',
      businessId: 'biz-1',
    );
    expect(listed.items, hasLength(1));
    expect(listed.items.single.id, saved.id);
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
    expect(remote.createCalls, 2);
    expect(remote.items, hasLength(1));
  });

  test(
    'update keeps the same id and can mark paid without creating cash',
    () async {
      final saved = await repository.create(
        ownerId: 'user-1',
        businessId: 'biz-1',
        currencyCode: 'BWP',
        draft: draft,
      );
      final updated = await repository.update(
        ownerId: 'user-1',
        businessId: 'biz-1',
        currencyCode: 'BWP',
        draft: ObligationDraft(
          title: saved.title,
          amountText: '800.00',
          dueOn: saved.dueOn,
          category: saved.category,
          status: CommitmentStatus.paid,
          idempotencyKey: saved.idempotencyKey,
          existingId: saved.id,
        ),
      );
      expect(updated.id, saved.id);
      expect(updated.status, CommitmentStatus.paid);
    },
  );

  test('owner isolation rejects another business', () async {
    expect(
      () => repository.create(
        ownerId: 'user-b',
        businessId: 'biz-b',
        currencyCode: 'BWP',
        draft: draft,
      ),
      throwsA(isA<AuthFailure>()),
    );
  });

  test('failed refresh keeps confirmed cache and labels it stale', () async {
    await repository.create(
      ownerId: 'user-1',
      businessId: 'biz-1',
      currencyCode: 'BWP',
      draft: draft,
    );
    remote.nextError = const AuthFailure.network();
    final snapshot = await repository.listAllConfirmed(
      ownerId: 'user-1',
      businessId: 'biz-1',
    );
    expect(snapshot.isStale, isTrue);
    expect(snapshot.items, hasLength(1));
    expect(snapshot.refreshError, isNotNull);
  });
}
