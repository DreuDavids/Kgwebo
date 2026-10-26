import 'dart:convert';

import '../../../app/supabase/kgwebo_supabase.dart';
import '../application/copilot_llm_client.dart';
import '../application/financial_read_port.dart';
import '../domain/copilot_turn.dart';

class GeminiEdgeCopilotClient implements CopilotLlmClient {
  const GeminiEdgeCopilotClient();

  @override
  Future<CopilotLlmDraft?> complete({
    required String userText,
    required VerifiedFinancialSnapshot? snapshot,
    required List<String> recommendationTitles,
  }) async {
    if (!kgweboSupabaseIsInitialized) {
      return null;
    }
    try {
      final response = await kgweboSupabase.functions.invoke(
        'kgwebo-copilot',
        body: {
          'message': userText,
          'recommendationTitles': recommendationTitles,
          'snapshot':
              snapshot == null
                  ? null
                  : {
                    'currencyCode': snapshot.currencyCode,
                    'recordedCashMinor': snapshot.recordedCashMinor,
                    'recordedSalesMinor': snapshot.recordedSalesMinor,
                    'recordedExpensesMinor': snapshot.recordedExpensesMinor,
                    'netOperatingResultMinor': snapshot.netOperatingResultMinor,
                    'periodLabel': snapshot.periodLabel,
                    'source': snapshot.source,
                  },
        },
      );
      final data = response.data;
      if (data is! Map) {
        return null;
      }
      final map = Map<String, dynamic>.from(data);
      if (map['error'] != null) {
        return null;
      }
      final transactions = map['transactions'];
      return CopilotLlmDraft(
        reply: map['reply'] as String?,
        intent: map['intent'] as String?,
        chart: map['chart'] as String?,
        navigate: map['navigate'] as String?,
        languageCode: map['language'] as String?,
        transactionsJson:
            transactions == null
                ? null
                : jsonEncode({'transactions': transactions}),
      );
    } catch (_) {
      return null;
    }
  }
}
