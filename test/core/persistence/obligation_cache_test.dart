import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/persistence/kgwebo_database.dart';
import 'package:kgwebo/core/persistence/obligation_cache.dart';

import '../../helpers/fake_obligations.dart';

void main() {
  late KgweboDatabase database;
  late ObligationCache cache;

  setUp(() {
    database = KgweboDatabase.memory();
    cache = ObligationCache(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('insert and read a confirmed commitment for the owner', () async {
    final rent = sampleObligation();
    await cache.upsertConfirmed(rent);
    final loaded = await cache.findConfirmed(
      ownerId: 'user-1',
      businessId: 'biz-1',
      obligationId: rent.id,
    );
    expect(loaded, isNotNull);
    expect(loaded!.amountMinor, 80000);
    expect(loaded.title, 'Shop rent');
  });

  test('queries only the current owner and business', () async {
    await cache.upsertConfirmed(sampleObligation());
    await cache.upsertConfirmed(
      sampleObligation(id: 'ob-b', ownerId: 'user-b', businessId: 'biz-b'),
    );
    final listed = await cache.listConfirmed(
      ownerId: 'user-1',
      businessId: 'biz-1',
    );
    expect(listed, hasLength(1));
    expect(listed.single.id, 'ob-rent');
  });
}
