import 'recommendation_rules.dart';

enum RecommendationStatus { active, dismissed, resolved }

class PersistedRecommendationState {
  const PersistedRecommendationState({
    required this.id,
    required this.ruleKey,
    required this.conditionKey,
    required this.status,
  });

  final String id;
  final RecommendationRuleKey ruleKey;
  final String conditionKey;
  final RecommendationStatus status;
}

class RecommendationMutation {
  const RecommendationMutation({
    required this.ruleKey,
    required this.conditionKey,
    required this.status,
    this.existingId,
  });

  final RecommendationRuleKey ruleKey;
  final String conditionKey;
  final RecommendationStatus status;
  final String? existingId;

  bool get isInsert => existingId == null;
}

/// Deduplicates by rule key and preserves dismissal until the condition changes.
abstract final class RecommendationLifecycle {
  static RecommendationStatus parseStatus(String raw) {
    return switch (raw) {
      'active' => RecommendationStatus.active,
      'dismissed' => RecommendationStatus.dismissed,
      'resolved' => RecommendationStatus.resolved,
      _ => throw FormatException('Unknown recommendation status', raw),
    };
  }

  static String statusToStorage(RecommendationStatus status) {
    return switch (status) {
      RecommendationStatus.active => 'active',
      RecommendationStatus.dismissed => 'dismissed',
      RecommendationStatus.resolved => 'resolved',
    };
  }

  static List<RecommendationMutation> reconcile({
    required List<PersistedRecommendationState> existing,
    required List<GeneratedRecommendation> generated,
  }) {
    final byRule = <RecommendationRuleKey, PersistedRecommendationState>{};
    for (final row in existing) {
      byRule.putIfAbsent(row.ruleKey, () => row);
    }
    final mutations = <RecommendationMutation>[];
    final seen = <RecommendationRuleKey>{};

    for (final item in generated) {
      seen.add(item.ruleKey);
      final current = byRule[item.ruleKey];
      if (current == null) {
        mutations.add(
          RecommendationMutation(
            ruleKey: item.ruleKey,
            conditionKey: item.conditionKey,
            status: RecommendationStatus.active,
          ),
        );
        continue;
      }
      switch (current.status) {
        case RecommendationStatus.active:
          if (current.conditionKey != item.conditionKey) {
            mutations.add(
              RecommendationMutation(
                ruleKey: item.ruleKey,
                conditionKey: item.conditionKey,
                status: RecommendationStatus.active,
                existingId: current.id,
              ),
            );
          }
        case RecommendationStatus.dismissed:
          if (current.conditionKey != item.conditionKey) {
            mutations.add(
              RecommendationMutation(
                ruleKey: item.ruleKey,
                conditionKey: item.conditionKey,
                status: RecommendationStatus.active,
                existingId: current.id,
              ),
            );
          }
        case RecommendationStatus.resolved:
          mutations.add(
            RecommendationMutation(
              ruleKey: item.ruleKey,
              conditionKey: item.conditionKey,
              status: RecommendationStatus.active,
              existingId: current.id,
            ),
          );
      }
    }

    for (final row in existing) {
      if (seen.contains(row.ruleKey)) {
        continue;
      }
      if (row.status == RecommendationStatus.resolved) {
        continue;
      }
      mutations.add(
        RecommendationMutation(
          ruleKey: row.ruleKey,
          conditionKey: row.conditionKey,
          status: RecommendationStatus.resolved,
          existingId: row.id,
        ),
      );
    }

    return List<RecommendationMutation>.unmodifiable(mutations);
  }

  static bool isVisibleActive({
    required GeneratedRecommendation generated,
    required PersistedRecommendationState? persisted,
  }) {
    if (persisted == null) {
      return true;
    }
    return switch (persisted.status) {
      RecommendationStatus.active => true,
      RecommendationStatus.resolved => true,
      RecommendationStatus.dismissed =>
        persisted.conditionKey != generated.conditionKey,
    };
  }
}
