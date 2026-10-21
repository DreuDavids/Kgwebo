import '../../authentication/domain/auth_failure.dart';
import '../../../core/finance/recommendation_lifecycle.dart';
import '../application/recommendation_repository.dart';
import '../domain/business_recommendation.dart';
import '../domain/recommendation_snapshot.dart';

class PreviewRecommendationRepository implements RecommendationRepository {
  static const _previewMessage =
      'Preview and demo modes do not write recommendations to Supabase.';

  @override
  Future<RecommendationListSnapshot> listAllConfirmed({
    required String ownerId,
    required String businessId,
  }) async {
    return const RecommendationListSnapshot(
      items: [],
      origin: RecommendationDataOrigin.remote,
    );
  }

  @override
  Future<BusinessRecommendation> upsert({
    required String ownerId,
    required String businessId,
    required RecommendationMutation mutation,
  }) async {
    throw const AuthFailure(_previewMessage);
  }

  @override
  Future<BusinessRecommendation> dismiss({
    required String ownerId,
    required String businessId,
    required String recommendationId,
    required String conditionKey,
  }) async {
    throw const AuthFailure(_previewMessage);
  }
}
