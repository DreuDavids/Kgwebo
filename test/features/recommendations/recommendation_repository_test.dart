import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/recommendation_lifecycle.dart';
import 'package:kgwebo/core/finance/recommendation_rules.dart';
import 'package:kgwebo/core/persistence/kgwebo_database.dart';
import 'package:kgwebo/core/persistence/recommendation_cache.dart';
import 'package:kgwebo/features/authentication/domain/auth_failure.dart';
import 'package:kgwebo/features/recommendations/data/cached_recommendation_repository.dart';

import '../../helpers/fake_recommendations.dart';

void main() {
  late FakeRecommendationRepository remote;
  late KgweboDatabase database;
  late CachedRecommendationRepository repository;

  setUp(() {
    remote = FakeRecommendationRepository();
    database = KgweboDatabase.memory();
    repository = CachedRecommendationRepository(
      remote: remote,
      cache: RecommendationCache(database),
      currentOwnerId: () => 'user-1',
    );
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'upsert persists once per rule and survives a second evaluate',
    () async {
      final mutation = RecommendationMutation(
        ruleKey: RecommendationRuleKey.overdueCommitments,
        conditionKey: 'overdue:rent',
        status: RecommendationStatus.active,
      );
      final first = await repository.upsert(
        ownerId: 'user-1',
        businessId: 'biz-1',
        mutation: mutation,
      );
      final second = await repository.upsert(
        ownerId: 'user-1',
        businessId: 'biz-1',
        mutation: mutation,
      );
      expect(second.id, first.id);
      expect(remote.items, hasLength(1));
    },
  );

  test('dismiss is stored and still present after a list refresh', () async {
    final saved = await repository.upsert(
      ownerId: 'user-1',
      businessId: 'biz-1',
      mutation: RecommendationMutation(
        ruleKey: RecommendationRuleKey.overdueCommitments,
        conditionKey: 'overdue:rent',
        status: RecommendationStatus.active,
      ),
    );
    await repository.dismiss(
      ownerId: 'user-1',
      businessId: 'biz-1',
      recommendationId: saved.id,
      conditionKey: 'overdue:rent',
    );
    final listed = await repository.listAllConfirmed(
      ownerId: 'user-1',
      businessId: 'biz-1',
    );
    expect(listed.items.single.status, RecommendationStatus.dismissed);
  });

  test('owner isolation rejects another business', () async {
    expect(
      () => repository.upsert(
        ownerId: 'user-b',
        businessId: 'biz-b',
        mutation: RecommendationMutation(
          ruleKey: RecommendationRuleKey.lowStock,
          conditionKey: 'products:a,b',
          status: RecommendationStatus.active,
        ),
      ),
      throwsA(isA<AuthFailure>()),
    );
  });

  test('failed refresh keeps confirmed cache and labels it stale', () async {
    await repository.upsert(
      ownerId: 'user-1',
      businessId: 'biz-1',
      mutation: RecommendationMutation(
        ruleKey: RecommendationRuleKey.overdueCommitments,
        conditionKey: 'overdue:rent',
        status: RecommendationStatus.active,
      ),
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
