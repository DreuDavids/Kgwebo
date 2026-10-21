import '../../../core/finance/recommendation_lifecycle.dart';

Map<String, dynamic> recommendationWriteMap({
  required String businessId,
  required RecommendationMutation mutation,
}) {
  return {
    'business_id': businessId,
    'rule_key': mutation.ruleKey.storage,
    'condition_key': mutation.conditionKey,
    'status': RecommendationLifecycle.statusToStorage(mutation.status),
  };
}
