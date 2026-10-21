import '../../../core/finance/recommendation_lifecycle.dart';
import '../domain/business_recommendation.dart';
import '../domain/recommendation_snapshot.dart';

abstract class RecommendationRepository {
  Future<RecommendationListSnapshot> listAllConfirmed({
    required String ownerId,
    required String businessId,
  });

  Future<BusinessRecommendation> upsert({
    required String ownerId,
    required String businessId,
    required RecommendationMutation mutation,
  });

  Future<BusinessRecommendation> dismiss({
    required String ownerId,
    required String businessId,
    required String recommendationId,
    required String conditionKey,
  });
}
