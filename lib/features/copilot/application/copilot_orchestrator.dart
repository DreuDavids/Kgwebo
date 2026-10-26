import '../../recommendations/domain/visible_recommendation.dart';
import '../domain/copilot_turn.dart';
import 'copilot_grounding.dart';
import 'copilot_llm_client.dart';
import 'financial_read_port.dart';
import 'heuristic_extractor.dart';

class CopilotOrchestrator {
  CopilotOrchestrator({
    required CopilotLlmClient llm,
    required FinancialReadPort finances,
    this.recommendations = const [],
  }) : _llm = llm,
       _finances = finances;

  final CopilotLlmClient _llm;
  final FinancialReadPort _finances;
  final List<VisibleRecommendation> recommendations;

  Future<CopilotTurn> handle(String userText) async {
    final snapshot = await _finances.currentSnapshot();
    final localDrafts = extractHeuristicDrafts(
      userText,
      currencyCode: snapshot?.currencyCode ?? 'BWP',
    );
    CopilotLlmDraft? llmDraft;
    var offline = false;
    try {
      llmDraft = await _llm.complete(
        userText: userText,
        snapshot: snapshot,
        recommendationTitles:
            recommendations.map((item) => item.title).toList(),
      );
    } catch (_) {
      offline = true;
      llmDraft = null;
    }
    if (llmDraft == null) {
      offline = true;
    }
    return groundCopilotTurn(
      userText: userText,
      snapshot: snapshot,
      llm: llmDraft,
      recommendations: recommendations,
      localDrafts: localDrafts,
      offline: offline,
    );
  }
}
