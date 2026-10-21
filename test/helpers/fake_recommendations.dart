import 'package:kgwebo/core/finance/recommendation_lifecycle.dart';
import 'package:kgwebo/core/finance/recommendation_rules.dart';
import 'package:kgwebo/features/authentication/domain/auth_failure.dart';
import 'package:kgwebo/features/recommendations/application/recommendation_repository.dart';
import 'package:kgwebo/features/recommendations/domain/business_recommendation.dart';
import 'package:kgwebo/features/recommendations/domain/recommendation_snapshot.dart';

class FakeRecommendationRepository implements RecommendationRepository {
  FakeRecommendationRepository({
    this.ownerId = 'user-1',
    this.businessId = 'biz-1',
  });

  final String ownerId;
  final String businessId;
  final List<BusinessRecommendation> items = [];
  AuthFailure? nextError;
  AuthFailure? failReads;
  AuthFailure? failWrites;
  int listCalls = 0;
  int upsertCalls = 0;
  int dismissCalls = 0;

  @override
  Future<RecommendationListSnapshot> listAllConfirmed({
    required String ownerId,
    required String businessId,
  }) async {
    listCalls += 1;
    if (failReads != null) {
      throw failReads!;
    }
    _throwIfNeeded(nextError);
    _require(ownerId, businessId);
    return RecommendationListSnapshot.remote(
      items
          .where(
            (item) => item.belongsTo(ownerId: ownerId, businessId: businessId),
          )
          .toList(),
    );
  }

  @override
  Future<BusinessRecommendation> upsert({
    required String ownerId,
    required String businessId,
    required RecommendationMutation mutation,
  }) async {
    upsertCalls += 1;
    _throwIfNeeded(failWrites ?? nextError);
    _require(ownerId, businessId);
    final now = DateTime.utc(2026, 10, 21, 12);
    if (mutation.existingId != null) {
      final index = items.indexWhere(
        (item) =>
            item.id == mutation.existingId &&
            item.belongsTo(ownerId: ownerId, businessId: businessId),
      );
      if (index < 0) {
        throw const AuthFailure(
          'Could not update this recommendation. It may not exist or you may not own it.',
        );
      }
      final updated = BusinessRecommendation(
        id: items[index].id,
        businessId: businessId,
        ownerId: ownerId,
        createdBy: ownerId,
        ruleKey: mutation.ruleKey,
        conditionKey: mutation.conditionKey,
        status: mutation.status,
        createdAt: items[index].createdAt,
        updatedAt: now,
      );
      items[index] = updated;
      return updated;
    }
    final existingIndex = items.indexWhere(
      (item) =>
          item.ruleKey == mutation.ruleKey &&
          item.belongsTo(ownerId: ownerId, businessId: businessId),
    );
    if (existingIndex >= 0) {
      final updated = BusinessRecommendation(
        id: items[existingIndex].id,
        businessId: businessId,
        ownerId: ownerId,
        createdBy: ownerId,
        ruleKey: mutation.ruleKey,
        conditionKey: mutation.conditionKey,
        status: mutation.status,
        createdAt: items[existingIndex].createdAt,
        updatedAt: now,
      );
      items[existingIndex] = updated;
      return updated;
    }
    final created = BusinessRecommendation(
      id: 'rec-${items.length + 1}',
      businessId: businessId,
      ownerId: ownerId,
      createdBy: ownerId,
      ruleKey: mutation.ruleKey,
      conditionKey: mutation.conditionKey,
      status: mutation.status,
      createdAt: now,
      updatedAt: now,
    );
    items.add(created);
    return created;
  }

  @override
  Future<BusinessRecommendation> dismiss({
    required String ownerId,
    required String businessId,
    required String recommendationId,
    required String conditionKey,
  }) async {
    dismissCalls += 1;
    _throwIfNeeded(failWrites ?? nextError);
    _require(ownerId, businessId);
    final index = items.indexWhere(
      (item) =>
          item.id == recommendationId &&
          item.belongsTo(ownerId: ownerId, businessId: businessId),
    );
    if (index < 0) {
      throw const AuthFailure(
        'Could not dismiss this recommendation. It may not exist or you may not own it.',
      );
    }
    final current = items[index];
    final updated = BusinessRecommendation(
      id: current.id,
      businessId: current.businessId,
      ownerId: current.ownerId,
      createdBy: current.createdBy,
      ruleKey: current.ruleKey,
      conditionKey: conditionKey,
      status: RecommendationStatus.dismissed,
      createdAt: current.createdAt,
      updatedAt: DateTime.utc(2026, 10, 21, 13),
    );
    items[index] = updated;
    return updated;
  }

  void _require(String ownerId, String businessId) {
    if (ownerId != this.ownerId || businessId != this.businessId) {
      throw const AuthFailure(
        'This business does not belong to the signed-in account.',
      );
    }
  }

  void _throwIfNeeded(AuthFailure? error) {
    nextError = null;
    if (error != null) {
      throw error;
    }
  }
}

BusinessRecommendation sampleRecommendation({
  String id = 'rec-1',
  String ownerId = 'user-1',
  String businessId = 'biz-1',
  RecommendationRuleKey ruleKey = RecommendationRuleKey.overdueCommitments,
  String conditionKey = 'overdue:rent',
  RecommendationStatus status = RecommendationStatus.active,
}) {
  final now = DateTime.utc(2026, 10, 21, 8);
  return BusinessRecommendation(
    id: id,
    businessId: businessId,
    ownerId: ownerId,
    createdBy: ownerId,
    ruleKey: ruleKey,
    conditionKey: conditionKey,
    status: status,
    createdAt: now,
    updatedAt: now,
  );
}
