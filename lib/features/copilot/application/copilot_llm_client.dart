import '../domain/copilot_turn.dart';
import 'financial_read_port.dart';

abstract class CopilotLlmClient {
  Future<CopilotLlmDraft?> complete({
    required String userText,
    required VerifiedFinancialSnapshot? snapshot,
    required List<String> recommendationTitles,
  });
}

class NullCopilotLlmClient implements CopilotLlmClient {
  const NullCopilotLlmClient();

  @override
  Future<CopilotLlmDraft?> complete({
    required String userText,
    required VerifiedFinancialSnapshot? snapshot,
    required List<String> recommendationTitles,
  }) async {
    return null;
  }
}

class ScriptedCopilotLlmClient implements CopilotLlmClient {
  ScriptedCopilotLlmClient(this.draft);

  CopilotLlmDraft? draft;
  int completeCalls = 0;

  @override
  Future<CopilotLlmDraft?> complete({
    required String userText,
    required VerifiedFinancialSnapshot? snapshot,
    required List<String> recommendationTitles,
  }) async {
    completeCalls += 1;
    return draft;
  }
}
