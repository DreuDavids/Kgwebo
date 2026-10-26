import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/financial_engine.dart';
import 'package:kgwebo/core/finance/ledger_entry.dart';
import 'package:kgwebo/core/finance/business_calendar.dart';
import 'package:kgwebo/core/money/money_formatter.dart';
import 'package:kgwebo/features/copilot/application/copilot_grounding.dart';
import 'package:kgwebo/features/copilot/application/financial_read_port.dart';
import 'package:kgwebo/features/copilot/domain/copilot_turn.dart';
import 'package:kgwebo/features/copilot/domain/extracted_draft.dart';
import 'package:kgwebo/features/recommendations/domain/visible_recommendation.dart';
import 'package:kgwebo/core/finance/recommendation_rules.dart';

void main() {
  const snapshot = VerifiedFinancialSnapshot(
    currencyCode: 'BWP',
    recordedCashMinor: 255000,
    recordedSalesMinor: 50000,
    recordedExpensesMinor: 10000,
    netOperatingResultMinor: 40000,
    periodLabel: 'October 2026',
    source: 'FinancialEngine',
  );

  final cash = MoneyFormatter.formatMinor(255000, currencyCode: 'BWP');

  test('replaces invented cash with FinancialEngine figures', () {
    final turn = groundCopilotTurn(
      userText: 'How much cash do I have?',
      snapshot: snapshot,
      llm: const CopilotLlmDraft(
        intent: 'finances',
        reply: 'You have P 9,999.00 in cash.',
      ),
    );

    expect(turn.source, CopilotSource.verifiedRecords);
    expect(turn.snapshot, snapshot);
    expect(turn.reply, contains(cash));
    expect(turn.reply, isNot(contains('9,999.00')));
    expect(turn.chart, CopilotChartKind.totals);
  });

  test('keeps a reply that only restates verified amounts', () {
    final turn = groundCopilotTurn(
      userText: 'What is my cash?',
      snapshot: snapshot,
      llm: CopilotLlmDraft(
        intent: 'finances',
        reply: 'Recorded cash is $cash for October 2026.',
      ),
    );

    expect(turn.reply, contains(cash));
    expect(turn.source, CopilotSource.verifiedRecords);
  });

  test('does not invent a balance when there is no snapshot', () {
    final turn = groundCopilotTurn(
      userText: 'What is my profit?',
      snapshot: null,
      llm: const CopilotLlmDraft(
        intent: 'finances',
        reply: 'Your profit is P 1,000.00',
      ),
    );

    expect(turn.source, CopilotSource.needsRecords);
    expect(turn.snapshot, isNull);
    expect(turn.reply.toLowerCase(), contains('recorded'));
    expect(turn.reply, isNot(contains('1,000.00')));
  });

  test('drops model-invented recommendations', () {
    const real = VisibleRecommendation(
      generated: GeneratedRecommendation(
        ruleKey: RecommendationRuleKey.expensesExceedSales,
        conditionKey: 'expenses_exceed_sales',
        category: RecommendationCategory.operations,
        severity: RecommendationSeverity.medium,
        title: 'Expenses are higher than sales',
        explanation: 'Recorded expenses are larger than recorded sales.',
        evidence: 'From FinancialEngine',
        suggestedAction: 'Review Money',
        destination: RecommendationDestination.transactions,
      ),
    );

    final turn = groundCopilotTurn(
      userText: 'What should I watch?',
      snapshot: snapshot,
      recommendations: const [real],
      llm: const CopilotLlmDraft(
        intent: 'recommendations',
        reply: 'You should buy Bitcoin. Also P 50,000.00 is missing.',
      ),
    );

    expect(turn.recommendations, hasLength(1));
    expect(turn.recommendations.single.title, real.title);
    expect(turn.recommendations.single.explanation, real.explanation);
    expect(turn.reply, isNot(contains('Bitcoin')));
    expect(turn.reply, isNot(contains('50,000.00')));
  });

  test('spec cash fixture remains 2550 pula through the engine', () {
    final october = ReportingPeriod(
      startInclusive: BusinessCalendar.utcFromGaborone(
        year: 2026,
        month: 10,
        day: 1,
      ),
      endExclusive: BusinessCalendar.utcFromGaborone(
        year: 2026,
        month: 11,
        day: 1,
      ),
    );
    final asOf = BusinessCalendar.utcFromGaborone(
      year: 2026,
      month: 10,
      day: 21,
      hour: 12,
    );
    final occurred = BusinessCalendar.utcFromGaborone(
      year: 2026,
      month: 10,
      day: 10,
    );

    LedgerEntry entry({
      required String id,
      required MoneyMovementType type,
      required int amount,
    }) {
      return LedgerEntry(
        id: id,
        type: type,
        amountMinor: amount,
        currencyCode: 'BWP',
        occurredAt: occurred,
        paymentStatus: PaymentStatus.paid,
      );
    }

    final summary = FinancialEngine.summarize(
      entries: [
        entry(id: 'sale', type: MoneyMovementType.sale, amount: 50000),
        entry(id: 'exp', type: MoneyMovementType.expense, amount: 10000),
        entry(
          id: 'in',
          type: MoneyMovementType.ownerContribution,
          amount: 20000,
        ),
        entry(id: 'out', type: MoneyMovementType.ownerWithdrawal, amount: 5000),
      ],
      openingCashMinor: 200000,
      currencyCode: 'BWP',
      period: october,
      asOf: asOf,
    );

    expect(summary.currentCashMinor, 255000);
    final grounded = groundCopilotTurn(
      userText: 'ke na le madi a kae?',
      snapshot: VerifiedFinancialSnapshot(
        currencyCode: summary.currencyCode,
        recordedCashMinor: summary.currentCashMinor,
        recordedSalesMinor: summary.recordedSalesMinor,
        recordedExpensesMinor: summary.recordedOperatingExpensesMinor,
        netOperatingResultMinor: summary.netRecordedOperatingResultMinor,
        periodLabel: 'October 2026',
        source: 'FinancialEngine',
      ),
      llm: const CopilotLlmDraft(
        intent: 'finances',
        languageCode: 'tn',
        reply: 'O na le P 80.00.',
      ),
    );
    expect(grounded.snapshot!.recordedCashMinor, 255000);
    expect(grounded.reply, isNot(contains('80.00')));
    expect(
      grounded.reply,
      contains(MoneyFormatter.formatMinor(255000, currencyCode: 'BWP')),
    );
  });

  test('drops a chat reply that invents a money figure', () {
    final turn = groundCopilotTurn(
      userText: 'Can you greet me?',
      snapshot: snapshot,
      llm: const CopilotLlmDraft(
        intent: 'chat',
        reply: 'Hello. Record it, and you will have P 50.00 extra.',
      ),
    );

    expect(turn.reply, isNot(contains('50.00')));
    expect(turn.source, isNot(CopilotSource.verifiedRecords));
  });

  test('strips an LLM draft amount the user never named in pula', () {
    final turn = groundCopilotTurn(
      userText: 'I bought domains',
      snapshot: snapshot,
      llm: const CopilotLlmDraft(
        intent: 'drafts',
        transactionsJson:
            '{"transactions":[{"type":"expense","amount_pula":"999.00","item":"domains","category":"fees"}]}',
      ),
    );

    expect(turn.drafts, hasLength(1));
    expect(turn.drafts.single.amountMinor, isNull);
    expect(turn.drafts.single.isComplete, isFalse);
  });

  test('asks how to record a sale instead of opening the form', () {
    final turn = groundCopilotTurn(
      userText: 'I want to record a sale',
      snapshot: snapshot,
    );

    expect(turn.offer, CopilotOffer.recordSale);
    expect(turn.navigateRouteName, isNull);
    expect(turn.reply.toLowerCase(), contains('help'));
    expect(turn.reply.toLowerCase(), contains('open'));
  });

  test(
    'a sale intent without an amount stays an offer, not an empty draft',
    () {
      final turn = groundCopilotTurn(
        userText: 'I want to record a sale',
        snapshot: snapshot,
        localDrafts: const [ExtractedDraft(type: MoneyMovementType.sale)],
      );

      expect(turn.offer, CopilotOffer.recordSale);
      expect(turn.drafts, isEmpty);
      expect(turn.navigateRouteName, isNull);
    },
  );

  test('opens the sale form only when the user asks to open it', () {
    final turn = groundCopilotTurn(
      userText: 'Open the record sale page',
      snapshot: snapshot,
      llm: const CopilotLlmDraft(intent: 'navigate', navigate: 'recordSale'),
    );

    expect(turn.offer, CopilotOffer.none);
    expect(turn.navigateRouteName, 'record-sale');
  });

  test('keeps a unit price times quantity the user named in pula', () {
    final turn = groundCopilotTurn(
      userText: 'I bought two domains at 50 pula each',
      snapshot: snapshot,
      llm: const CopilotLlmDraft(
        intent: 'drafts',
        transactionsJson:
            '{"transactions":[{"type":"expense","amount_pula":"100.00","item":"domains","quantity":2,"category":"fees"}]}',
      ),
    );

    expect(turn.drafts.single.item, 'domains');
    expect(turn.drafts.single.amountMinor, 10000);
  });

  test('keeps an LLM draft amount the user named in pula', () {
    final turn = groundCopilotTurn(
      userText: 'Please log an expense of P80 for consulting',
      snapshot: snapshot,
      llm: const CopilotLlmDraft(
        intent: 'drafts',
        transactionsJson:
            '{"transactions":[{"type":"expense","amount_pula":"80.00","category":"fees"}]}',
      ),
    );

    expect(turn.drafts.single.amountMinor, 8000);
  });

  test('records a complete bought sentence instead of asking again', () {
    final turn = groundCopilotTurn(
      userText:
          'hey I bought 2 domains at 50 each, can you please record this for me',
      snapshot: snapshot,
    );

    expect(turn.offer, CopilotOffer.none);
    expect(turn.source, CopilotSource.drafts);
    expect(turn.drafts, hasLength(1));
    expect(turn.drafts.single.item, 'domains');
    expect(turn.drafts.single.amountMinor, 10000);
    expect(turn.drafts.single.paymentStatus, PaymentStatus.paid);
    expect(turn.reply.toLowerCase(), isNot(contains('help me')));
    expect(turn.reply.toLowerCase(), isNot(contains('tell me the amount')));
    expect(turn.reply.toLowerCase(), contains('domains'));
  });

  test('draft copy uses the profile currency, not pula', () {
    const zarSnapshot = VerifiedFinancialSnapshot(
      currencyCode: 'ZAR',
      recordedCashMinor: 255000,
      recordedSalesMinor: 50000,
      recordedExpensesMinor: 10000,
      netOperatingResultMinor: 40000,
      periodLabel: 'October 2026',
      source: 'FinancialEngine',
    );

    final turn = groundCopilotTurn(
      userText: 'I bought 2 domains at 50 each',
      snapshot: zarSnapshot,
    );

    expect(turn.drafts.single.amountMinor, 10000);
    expect(turn.drafts.single.hasForeignCurrency, isFalse);
    expect(turn.reply.toLowerCase(), contains('rand'));
    expect(turn.reply.toLowerCase(), isNot(contains('pula')));
  });

  test('keeps a bare unit price times quantity in the profile currency', () {
    final turn = groundCopilotTurn(
      userText: 'I bought two domains at 50 each',
      snapshot: snapshot,
      llm: const CopilotLlmDraft(
        intent: 'drafts',
        transactionsJson:
            '{"transactions":[{"type":"expense","amount_pula":"100.00","item":"domains","quantity":2,"category":"fees"}]}',
      ),
    );

    expect(turn.drafts.single.amountMinor, 10000);
    expect(turn.drafts.single.hasForeignCurrency, isFalse);
  });
}
