import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/persistence/business_cache.dart';
import 'package:kgwebo/core/persistence/business_mappers.dart';
import 'package:kgwebo/core/persistence/kgwebo_database.dart';
import 'package:kgwebo/features/onboarding/domain/business_profile.dart';

void main() {
  late KgweboDatabase database;
  late BusinessCache cache;

  const ownerA = BusinessProfile(
    id: 'biz-a',
    ownerId: 'user-a',
    name: 'Kgale Stall',
    businessType: 'Informal trader',
    countryCode: 'BW',
    currencyCode: 'BWP',
    openingBalanceMinor: 200000,
  );
  const ownerB = BusinessProfile(
    id: 'biz-b',
    ownerId: 'user-b',
    name: 'Broadhurst Shop',
    businessType: 'Retail shop',
    countryCode: 'BW',
    currencyCode: 'BWP',
    openingBalanceMinor: 5000,
  );

  setUp(() {
    database = KgweboDatabase.memory();
    cache = BusinessCache(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('schema version is 4', () {
    expect(database.schemaVersion, 4);
  });

  test('insert and read a confirmed business', () async {
    await cache.upsertConfirmed(ownerA);
    final loaded = await cache.findConfirmedForOwner('user-a');
    expect(loaded, isNotNull);
    expect(loaded!.id, 'biz-a');
    expect(loaded.openingBalanceMinor, 200000);
    expect(loaded.name, 'Kgale Stall');
  });

  test('updating the same business does not create a duplicate', () async {
    await cache.upsertConfirmed(ownerA);
    await cache.upsertConfirmed(
      ownerA.copyWith(name: 'Kgale Stall 2', openingBalanceMinor: 150000),
    );
    final rows = await database.select(database.cachedBusinesses).get();
    expect(rows, hasLength(1));
    expect(rows.single.remoteId, 'biz-a');
    expect(rows.single.name, 'Kgale Stall 2');
    expect(rows.single.openingBalanceMinor, 150000);
  });

  test('queries only the current owner', () async {
    await cache.upsertConfirmed(ownerA);
    await cache.upsertConfirmed(ownerB);
    final loadedA = await cache.findConfirmedForOwner('user-a');
    final loadedB = await cache.findConfirmedForOwner('user-b');
    expect(loadedA!.id, 'biz-a');
    expect(loadedB!.id, 'biz-b');
    expect(await cache.findConfirmedForOwner('user-c'), isNull);
  });

  test('empty databases return null rather than another owner', () async {
    expect(await cache.findConfirmedForOwner('user-a'), isNull);
  });

  test('unverified cache rows are not returned', () async {
    await database
        .into(database.cachedBusinesses)
        .insert(
          cachedCompanionFromProfile(
            ownerA,
          ).copyWith(syncStatus: const Value('pending')),
        );
    expect(await cache.findConfirmedForOwner('user-a'), isNull);
  });

  test('opening cash is preserved across cache writes', () async {
    await cache.upsertConfirmed(ownerA);
    final loaded = await cache.findConfirmedForOwner('user-a');
    expect(loaded!.openingBalanceMinor, 200000);
  });
}
