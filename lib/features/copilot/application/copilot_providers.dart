import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/application/session_controller.dart';
import '../../dashboard/application/dashboard_finance_controller.dart';
import '../../recommendations/application/recommendations_controller.dart';
import '../data/dashboard_financial_read_port.dart';
import '../data/device_copilot_voice.dart';
import '../data/gemini_edge_client.dart';
import 'copilot_book.dart';
import 'copilot_commit.dart';
import 'copilot_llm_client.dart';
import 'copilot_orchestrator.dart';
import 'copilot_voice.dart';
import 'financial_read_port.dart';

final copilotMotionProvider = Provider<bool>((ref) => true);

final copilotVoiceProvider = Provider<CopilotVoice>((ref) {
  return DeviceCopilotVoice();
});

final copilotLlmClientProvider = Provider<CopilotLlmClient>((ref) {
  return const GeminiEdgeCopilotClient();
});

final financialReadPortProvider = Provider<FinancialReadPort>((ref) {
  return DashboardFinancialReadPort(
    ref.watch(dashboardFinanceControllerProvider),
  );
});

final copilotOrchestratorProvider = Provider<CopilotOrchestrator>((ref) {
  final finances = ref.watch(financialReadPortProvider);
  return CopilotOrchestrator(
    llm: ref.watch(copilotLlmClientProvider),
    finances: finances,
    book: finances is CopilotBookPort ? finances as CopilotBookPort : null,
    recommendations: ref.watch(recommendationsControllerProvider).items,
  );
});

final copilotCommitProvider = Provider<CopilotLedgerCommit>((ref) {
  return CopilotLedgerCommit(ref.watch(transactionRepositoryProvider));
});
