import '../../recommendations/domain/visible_recommendation.dart';
import '../application/financial_read_port.dart';
import 'extracted_draft.dart';

enum CopilotSource {
  verifiedRecords,
  appGuidance,
  needsRecords,
  drafts,
  unknown,
}

enum CopilotChartKind { none, totals, cashPath }

enum CopilotOffer { none, recordSale, recordExpense }

class CopilotTurn {
  const CopilotTurn({
    required this.reply,
    required this.source,
    this.snapshot,
    this.chart = CopilotChartKind.none,
    this.recommendations = const [],
    this.drafts = const [],
    this.navigateRouteName,
    this.languageCode,
    this.offline = false,
    this.warning,
    this.offer = CopilotOffer.none,
  });

  final String reply;
  final CopilotSource source;
  final VerifiedFinancialSnapshot? snapshot;
  final CopilotChartKind chart;
  final List<VisibleRecommendation> recommendations;
  final List<ExtractedDraft> drafts;
  final String? navigateRouteName;
  final String? languageCode;
  final bool offline;
  final String? warning;
  final CopilotOffer offer;

  CopilotTurn copyWith({
    String? reply,
    CopilotSource? source,
    VerifiedFinancialSnapshot? snapshot,
    CopilotChartKind? chart,
    List<VisibleRecommendation>? recommendations,
    List<ExtractedDraft>? drafts,
    String? navigateRouteName,
    String? languageCode,
    bool? offline,
    String? warning,
    CopilotOffer? offer,
    bool clearNavigate = false,
  }) {
    return CopilotTurn(
      reply: reply ?? this.reply,
      source: source ?? this.source,
      snapshot: snapshot ?? this.snapshot,
      chart: chart ?? this.chart,
      recommendations: recommendations ?? this.recommendations,
      drafts: drafts ?? this.drafts,
      navigateRouteName:
          clearNavigate ? null : (navigateRouteName ?? this.navigateRouteName),
      languageCode: languageCode ?? this.languageCode,
      offline: offline ?? this.offline,
      warning: warning ?? this.warning,
      offer: offer ?? this.offer,
    );
  }
}

class CopilotLlmDraft {
  const CopilotLlmDraft({
    this.reply,
    this.intent,
    this.chart,
    this.navigate,
    this.languageCode,
    this.transactionsJson,
  });

  final String? reply;
  final String? intent;
  final String? chart;
  final String? navigate;
  final String? languageCode;
  final String? transactionsJson;
}
