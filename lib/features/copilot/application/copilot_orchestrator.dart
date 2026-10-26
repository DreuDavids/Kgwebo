import '../../recommendations/domain/visible_recommendation.dart';
import '../domain/copilot_session.dart';
import '../domain/copilot_turn.dart';
import 'copilot_book.dart';
import 'copilot_follow_up.dart';
import 'copilot_grounding.dart';
import 'copilot_intent.dart';
import 'copilot_llm_client.dart';
import 'financial_read_port.dart';
import 'heuristic_extractor.dart';

class CopilotOrchestrator {
  CopilotOrchestrator({
    required CopilotLlmClient llm,
    required FinancialReadPort finances,
    this.book,
    this.recommendations = const [],
  }) : _llm = llm,
       _finances = finances;

  final CopilotLlmClient _llm;
  final FinancialReadPort _finances;
  final CopilotBookPort? book;
  final List<VisibleRecommendation> recommendations;

  Future<CopilotTurn> handle(
    String userText, {
    CopilotSession session = const CopilotSession(),
  }) async {
    final snapshot = await _finances.currentSnapshot();
    final currencyCode = snapshot?.currencyCode ?? 'BWP';
    final resolvedBook =
        await book?.currentBook() ?? CopilotBook(snapshot: snapshot);

    final followUp = CopilotFollowUp.apply(
      userText: userText,
      lastDrafts: session.lastDrafts,
      currencyCode: currencyCode,
    );
    if (followUp != null) {
      return groundCopilotTurn(
        userText: userText,
        snapshot: snapshot,
        book: resolvedBook,
        session: session,
        localDrafts: followUp,
        offline: false,
      );
    }

    final intent = classifyCopilotIntent(userText, currencyCode: currencyCode);
    final localDrafts = extractHeuristicDrafts(
      userText,
      currencyCode: currencyCode,
    );
    CopilotLlmDraft? llmDraft;
    var offline = false;
    try {
      llmDraft = await _llm.complete(
        userText: userText,
        snapshot: shouldSendCashSnapshot(intent) ? snapshot : null,
        currencyCode: currencyCode,
        recommendationTitles:
            recommendations.map((item) => item.title).toList(),
        bookDigest:
            intent == CopilotIntentKind.drafts
                ? null
                : bookDigest(
                  resolvedBook,
                  includeCash: shouldSendCashSnapshot(intent),
                ),
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
      book: resolvedBook,
      session: session,
      llm: llmDraft,
      recommendations: recommendations,
      localDrafts: localDrafts,
      offline: offline,
    );
  }
}
