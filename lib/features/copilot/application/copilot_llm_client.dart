import '../domain/copilot_turn.dart';
import 'financial_read_port.dart';

abstract class CopilotLlmClient {
  Future<CopilotLlmDraft?> complete({
    required String userText,
    required VerifiedFinancialSnapshot? snapshot,
    required List<String> recommendationTitles,
    required String currencyCode,
    Map<String, Object?>? bookDigest,
  });
}

class NullCopilotLlmClient implements CopilotLlmClient {
  const NullCopilotLlmClient();

  @override
  Future<CopilotLlmDraft?> complete({
    required String userText,
    required VerifiedFinancialSnapshot? snapshot,
    required List<String> recommendationTitles,
    required String currencyCode,
    Map<String, Object?>? bookDigest,
  }) async {
    return null;
  }
}

class ScriptedCopilotLlmClient implements CopilotLlmClient {
  ScriptedCopilotLlmClient(this.draft);

  CopilotLlmDraft? draft;
  int completeCalls = 0;
  VerifiedFinancialSnapshot? lastSnapshot;
  String? lastCurrencyCode;
  Map<String, Object?>? lastBookDigest;

  @override
  Future<CopilotLlmDraft?> complete({
    required String userText,
    required VerifiedFinancialSnapshot? snapshot,
    required List<String> recommendationTitles,
    required String currencyCode,
    Map<String, Object?>? bookDigest,
  }) async {
    completeCalls += 1;
    lastSnapshot = snapshot;
    lastCurrencyCode = currencyCode;
    lastBookDigest = bookDigest;
    return draft;
  }
}
