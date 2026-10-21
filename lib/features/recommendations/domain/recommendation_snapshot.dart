import 'business_recommendation.dart';

enum RecommendationDataOrigin { remote, localCache }

class RecommendationListSnapshot {
  const RecommendationListSnapshot({
    required this.items,
    required this.origin,
    this.refreshError,
  });

  factory RecommendationListSnapshot.remote(
    List<BusinessRecommendation> items,
  ) {
    return RecommendationListSnapshot(
      items: items,
      origin: RecommendationDataOrigin.remote,
    );
  }

  factory RecommendationListSnapshot.stale({
    required List<BusinessRecommendation> items,
    required String refreshError,
  }) {
    return RecommendationListSnapshot(
      items: items,
      origin: RecommendationDataOrigin.localCache,
      refreshError: refreshError,
    );
  }

  final List<BusinessRecommendation> items;
  final RecommendationDataOrigin origin;
  final String? refreshError;

  bool get isStale => origin == RecommendationDataOrigin.localCache;
}
