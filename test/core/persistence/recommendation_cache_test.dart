import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/persistence/kgwebo_database.dart';
import 'package:kgwebo/core/persistence/recommendation_cache.dart';

import '../../helpers/fake_recommendations.dart';

void main() {
  late KgweboDatabase database;
  late RecommendationCache cache;

  setUp(() {
    database = KgweboDatabase.memory();
    cache = RecommendationCache(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('schema version includes cached recommendations', () {
    expect(database.schemaVersion, 6);
  });

  test('insert and read a confirmed recommendation for the owner', () async {
    final rec = sampleRecommendation();
    await cache.upsertConfirmed(rec);
    final loaded = await cache.findConfirmed(
      ownerId: 'user-1',
      businessId: 'biz-1',
      recommendationId: rec.id,
    );
    expect(loaded, isNotNull);
    expect(loaded!.ruleKey, rec.ruleKey);
    expect(loaded.conditionKey, 'overdue:rent');
  });

  test('queries only the current owner and business', () async {
    await cache.upsertConfirmed(sampleRecommendation());
    await cache.upsertConfirmed(
      sampleRecommendation(id: 'rec-b', ownerId: 'user-b', businessId: 'biz-b'),
    );
    final listed = await cache.listConfirmed(
      ownerId: 'user-1',
      businessId: 'biz-1',
    );
    expect(listed, hasLength(1));
    expect(listed.single.id, 'rec-1');
  });
}
