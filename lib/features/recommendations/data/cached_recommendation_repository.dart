import '../../../core/logging/app_logger.dart';
import '../../../core/persistence/recommendation_cache.dart';
import '../../../core/finance/recommendation_lifecycle.dart';
import '../../authentication/domain/auth_failure.dart';
import '../application/recommendation_repository.dart';
import '../domain/business_recommendation.dart';
import '../domain/recommendation_snapshot.dart';

class CachedRecommendationRepository implements RecommendationRepository {
  CachedRecommendationRepository({
    required RecommendationRepository remote,
    required RecommendationCache cache,
    required String? Function() currentOwnerId,
  }) : _remote = remote,
       _cache = cache,
       _currentOwnerId = currentOwnerId;

  final RecommendationRepository _remote;
  final RecommendationCache _cache;
  final String? Function() _currentOwnerId;

  @override
  Future<RecommendationListSnapshot> listAllConfirmed({
    required String ownerId,
    required String businessId,
  }) async {
    _requireOwner(ownerId);
    try {
      final remote = await _remote.listAllConfirmed(
        ownerId: ownerId,
        businessId: businessId,
      );
      await _cache.replaceForBusiness(
        ownerId: ownerId,
        businessId: businessId,
        recommendations: remote.items,
      );
      return remote;
    } on AuthFailure catch (error) {
      if (!error.isRetryable) {
        rethrow;
      }
      final cached = await _cache.listConfirmed(
        ownerId: ownerId,
        businessId: businessId,
      );
      if (cached.isEmpty) {
        rethrow;
      }
      AppLogger.info(
        'Using confirmed recommendation cache after a remote read failure.',
      );
      return RecommendationListSnapshot.stale(
        items: cached,
        refreshError: error.message,
      );
    }
  }

  @override
  Future<BusinessRecommendation> upsert({
    required String ownerId,
    required String businessId,
    required RecommendationMutation mutation,
  }) async {
    _requireOwner(ownerId);
    final saved = await _remote.upsert(
      ownerId: ownerId,
      businessId: businessId,
      mutation: mutation,
    );
    final owned = _owned(saved, ownerId, businessId);
    await _cache.upsertConfirmed(owned);
    return owned;
  }

  @override
  Future<BusinessRecommendation> dismiss({
    required String ownerId,
    required String businessId,
    required String recommendationId,
    required String conditionKey,
  }) async {
    _requireOwner(ownerId);
    final saved = await _remote.dismiss(
      ownerId: ownerId,
      businessId: businessId,
      recommendationId: recommendationId,
      conditionKey: conditionKey,
    );
    final owned = _owned(saved, ownerId, businessId);
    await _cache.upsertConfirmed(owned);
    return owned;
  }

  void _requireOwner(String ownerId) {
    final current = _currentOwnerId();
    if (current == null) {
      throw AuthFailure.fromCode('session_expired');
    }
    if (current != ownerId) {
      throw const AuthFailure(
        'This business does not belong to the signed-in account.',
      );
    }
  }

  BusinessRecommendation _owned(
    BusinessRecommendation recommendation,
    String ownerId,
    String businessId,
  ) {
    if (!recommendation.belongsTo(ownerId: ownerId, businessId: businessId)) {
      throw const AuthFailure(
        'This recommendation does not belong to the signed-in account.',
      );
    }
    return recommendation;
  }
}
