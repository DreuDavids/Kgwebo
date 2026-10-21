import '../../../core/finance/recommendation_lifecycle.dart';
import '../../../core/finance/recommendation_rules.dart';

class BusinessRecommendation {
  const BusinessRecommendation({
    required this.id,
    required this.businessId,
    required this.ownerId,
    required this.createdBy,
    required this.ruleKey,
    required this.conditionKey,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String businessId;
  final String ownerId;
  final String createdBy;
  final RecommendationRuleKey ruleKey;
  final String conditionKey;
  final RecommendationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool belongsTo({required String ownerId, required String businessId}) {
    return this.ownerId == ownerId && this.businessId == businessId;
  }

  PersistedRecommendationState toPersistedState() {
    return PersistedRecommendationState(
      id: id,
      ruleKey: ruleKey,
      conditionKey: conditionKey,
      status: status,
    );
  }

  factory BusinessRecommendation.fromMap(
    Map<String, dynamic> row, {
    required String ownerId,
  }) {
    return BusinessRecommendation(
      id: row['id'] as String,
      businessId: row['business_id'] as String,
      ownerId: ownerId,
      createdBy: row['created_by'] as String,
      ruleKey: RecommendationRuleKey.parse(row['rule_key'] as String),
      conditionKey: row['condition_key'] as String,
      status: RecommendationLifecycle.parseStatus(row['status'] as String),
      createdAt: _stamp(row['created_at']),
      updatedAt: _stamp(row['updated_at']),
    );
  }

  static DateTime _stamp(Object raw) {
    if (raw is DateTime) {
      return raw.toUtc();
    }
    return DateTime.parse(raw.toString()).toUtc();
  }
}
