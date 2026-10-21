import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/recommendation_lifecycle.dart';
import 'package:kgwebo/core/finance/recommendation_rules.dart';

void main() {
  GeneratedRecommendation rec({
    RecommendationRuleKey rule = RecommendationRuleKey.overdueCommitments,
    String condition = 'overdue:rent',
  }) {
    return GeneratedRecommendation(
      ruleKey: rule,
      conditionKey: condition,
      category: RecommendationCategory.commitments,
      severity: RecommendationSeverity.high,
      title: 'Title',
      explanation: 'Explanation',
      evidence: 'Evidence',
      suggestedAction: 'Act',
      destination: RecommendationDestination.cashFlow,
    );
  }

  PersistedRecommendationState stored({
    String id = 'rec-1',
    RecommendationRuleKey rule = RecommendationRuleKey.overdueCommitments,
    String condition = 'overdue:rent',
    RecommendationStatus status = RecommendationStatus.active,
  }) {
    return PersistedRecommendationState(
      id: id,
      ruleKey: rule,
      conditionKey: condition,
      status: status,
    );
  }

  test('a new firing rule inserts one active recommendation', () {
    final mutations = RecommendationLifecycle.reconcile(
      existing: const [],
      generated: [rec()],
    );
    expect(mutations, hasLength(1));
    expect(mutations.single.isInsert, isTrue);
    expect(mutations.single.status, RecommendationStatus.active);
  });

  test('refreshing the same active condition does not duplicate', () {
    final mutations = RecommendationLifecycle.reconcile(
      existing: [stored()],
      generated: [rec()],
    );
    expect(mutations, isEmpty);
  });

  test('dismissal is preserved while the same condition still holds', () {
    final mutations = RecommendationLifecycle.reconcile(
      existing: [stored(status: RecommendationStatus.dismissed)],
      generated: [rec()],
    );
    expect(mutations, isEmpty);
    expect(
      RecommendationLifecycle.isVisibleActive(
        generated: rec(),
        persisted: stored(status: RecommendationStatus.dismissed),
      ),
      isFalse,
    );
  });

  test('a genuinely new condition reactivates a dismissed recommendation', () {
    final mutations = RecommendationLifecycle.reconcile(
      existing: [stored(status: RecommendationStatus.dismissed)],
      generated: [rec(condition: 'overdue:rent,loan')],
    );
    expect(mutations, hasLength(1));
    expect(mutations.single.existingId, 'rec-1');
    expect(mutations.single.status, RecommendationStatus.active);
    expect(mutations.single.conditionKey, 'overdue:rent,loan');
  });

  test('cleared conditions are marked resolved', () {
    final mutations = RecommendationLifecycle.reconcile(
      existing: [stored()],
      generated: const [],
    );
    expect(mutations.single.status, RecommendationStatus.resolved);
    expect(mutations.single.existingId, 'rec-1');
  });

  test('a previously resolved rule becomes active if it fires again', () {
    final mutations = RecommendationLifecycle.reconcile(
      existing: [stored(status: RecommendationStatus.resolved)],
      generated: [rec()],
    );
    expect(mutations.single.status, RecommendationStatus.active);
    expect(mutations.single.existingId, 'rec-1');
  });
}
