import 'package:drift/drift.dart';

import '../../features/recommendations/domain/business_recommendation.dart';
import '../finance/recommendation_lifecycle.dart';
import '../finance/recommendation_rules.dart';
import 'business_mappers.dart';
import 'kgwebo_database.dart';

BusinessRecommendation businessRecommendationFromCached(
  CachedRecommendation row,
) {
  if (row.ownerId.isEmpty || row.businessId.isEmpty) {
    throw StateError('Refusing a cache row without owner and business ids.');
  }
  if (row.syncStatus != confirmedSyncStatus) {
    throw StateError('Refusing an unverified recommendation cache row.');
  }
  return BusinessRecommendation(
    id: row.remoteId,
    businessId: row.businessId,
    ownerId: row.ownerId,
    createdBy: row.createdBy,
    ruleKey: RecommendationRuleKey.parse(row.ruleKey),
    conditionKey: row.conditionKey,
    status: RecommendationLifecycle.parseStatus(row.status),
    createdAt: row.createdAt.toUtc(),
    updatedAt: row.updatedAt.toUtc(),
  );
}

CachedRecommendationsCompanion cachedCompanionFromRecommendation(
  BusinessRecommendation recommendation,
) {
  return CachedRecommendationsCompanion.insert(
    remoteId: recommendation.id,
    ownerId: recommendation.ownerId,
    businessId: recommendation.businessId,
    createdBy: recommendation.createdBy,
    ruleKey: recommendation.ruleKey.storage,
    conditionKey: recommendation.conditionKey,
    status: RecommendationLifecycle.statusToStorage(recommendation.status),
    createdAt: recommendation.createdAt.toUtc(),
    updatedAt: recommendation.updatedAt.toUtc(),
    cachedAt: DateTime.now().toUtc(),
    syncStatus: const Value(confirmedSyncStatus),
  );
}
