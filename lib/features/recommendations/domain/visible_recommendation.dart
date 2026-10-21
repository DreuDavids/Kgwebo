import '../../../core/finance/recommendation_lifecycle.dart';
import '../../../core/finance/recommendation_rules.dart';
import 'business_recommendation.dart';

class VisibleRecommendation {
  const VisibleRecommendation({required this.generated, this.persisted});

  final GeneratedRecommendation generated;
  final BusinessRecommendation? persisted;

  RecommendationRuleKey get ruleKey => generated.ruleKey;
  RecommendationSeverity get severity => generated.severity;
  String get title => generated.title;
  String get explanation => generated.explanation;
  String get evidence => generated.evidence;
  String get suggestedAction => generated.suggestedAction;
  RecommendationDestination get destination => generated.destination;
  RecommendationStatus get status =>
      persisted?.status ?? RecommendationStatus.active;
}
