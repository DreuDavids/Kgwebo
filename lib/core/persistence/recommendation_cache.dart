import 'package:drift/drift.dart';

import '../../features/recommendations/domain/business_recommendation.dart';
import 'business_mappers.dart';
import 'kgwebo_database.dart';
import 'recommendation_mappers.dart';

class RecommendationCache {
  RecommendationCache(this._db);

  final KgweboDatabase _db;

  Future<List<BusinessRecommendation>> listConfirmed({
    required String ownerId,
    required String businessId,
  }) async {
    if (ownerId.isEmpty || businessId.isEmpty) {
      return const [];
    }
    final rows =
        await (_db.select(_db.cachedRecommendations)
              ..where(
                (tbl) =>
                    tbl.ownerId.equals(ownerId) &
                    tbl.businessId.equals(businessId) &
                    tbl.syncStatus.equals(confirmedSyncStatus),
              )
              ..orderBy([
                (tbl) => OrderingTerm.asc(tbl.ruleKey),
                (tbl) => OrderingTerm.asc(tbl.remoteId),
              ]))
            .get();
    return rows.map(_owned(ownerId, businessId)).toList();
  }

  Future<BusinessRecommendation?> findConfirmed({
    required String ownerId,
    required String businessId,
    required String recommendationId,
  }) async {
    if (ownerId.isEmpty || businessId.isEmpty || recommendationId.isEmpty) {
      return null;
    }
    final row =
        await (_db.select(_db.cachedRecommendations)..where(
          (tbl) =>
              tbl.ownerId.equals(ownerId) &
              tbl.businessId.equals(businessId) &
              tbl.remoteId.equals(recommendationId) &
              tbl.syncStatus.equals(confirmedSyncStatus),
        )).getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _owned(ownerId, businessId)(row);
  }

  Future<void> upsertConfirmed(BusinessRecommendation recommendation) {
    return upsertAll([recommendation]);
  }

  Future<void> upsertAll(List<BusinessRecommendation> recommendations) async {
    if (recommendations.isEmpty) {
      return;
    }
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.cachedRecommendations,
        recommendations.map(cachedCompanionFromRecommendation).toList(),
      );
    });
  }

  Future<void> replaceForBusiness({
    required String ownerId,
    required String businessId,
    required List<BusinessRecommendation> recommendations,
  }) async {
    if (ownerId.isEmpty || businessId.isEmpty) {
      return;
    }
    await _db.transaction(() async {
      await (_db.delete(_db.cachedRecommendations)..where(
        (tbl) =>
            tbl.ownerId.equals(ownerId) & tbl.businessId.equals(businessId),
      )).go();
      if (recommendations.isNotEmpty) {
        await _db.batch((batch) {
          batch.insertAllOnConflictUpdate(
            _db.cachedRecommendations,
            recommendations.map(cachedCompanionFromRecommendation).toList(),
          );
        });
      }
    });
  }

  Future<void> deleteForOwner(String ownerId) async {
    if (ownerId.isEmpty) {
      return;
    }
    await (_db.delete(_db.cachedRecommendations)
      ..where((tbl) => tbl.ownerId.equals(ownerId))).go();
  }

  BusinessRecommendation Function(CachedRecommendation row) _owned(
    String ownerId,
    String businessId,
  ) {
    return (row) {
      final recommendation = businessRecommendationFromCached(row);
      if (!recommendation.belongsTo(ownerId: ownerId, businessId: businessId)) {
        throw StateError(
          'Cache query returned a recommendation for a different owner or business.',
        );
      }
      return recommendation;
    };
  }
}
