import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/ledger_entry.dart';
import 'package:kgwebo/core/money/money_formatter.dart';
import 'package:kgwebo/features/copilot/application/copilot_llm_client.dart';
import 'package:kgwebo/features/copilot/application/copilot_orchestrator.dart';
import 'package:kgwebo/features/copilot/application/financial_read_port.dart';
import 'package:kgwebo/features/copilot/domain/copilot_turn.dart';

class _SnapshotPort implements FinancialReadPort {
  const _SnapshotPort(this.snapshot);

  final VerifiedFinancialSnapshot? snapshot;

  @override
  Future<VerifiedFinancialSnapshot?> currentSnapshot() async => snapshot;
}

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

  test('ignores model arithmetic and uses the engine snapshot', () async {
    final llm = ScriptedCopilotLlmClient(
      const CopilotLlmDraft(
        intent: 'finances',
        reply: 'Cash is P 9,999.00 after I added your sales.',
      ),
    );
    final orchestrator = CopilotOrchestrator(
      llm: llm,
      finances: const _SnapshotPort(snapshot),
    );

    final turn = await orchestrator.handle('How much cash do I have?');

    expect(llm.completeCalls, 1);
    expect(llm.lastSnapshot, isNotNull);
    expect(llm.lastCurrencyCode, 'BWP');
    expect(turn.source, CopilotSource.verifiedRecords);
    expect(
      turn.reply,
      contains(MoneyFormatter.formatMinor(255000, currencyCode: 'BWP')),
    );
    expect(turn.reply, isNot(contains('9,999.00')));
    expect(turn.chart, CopilotChartKind.totals);
  });

  test('still answers cash questions when the model is offline', () async {
    final orchestrator = CopilotOrchestrator(
      llm: const NullCopilotLlmClient(),
      finances: const _SnapshotPort(snapshot),
    );

    final turn = await orchestrator.handle('How much cash do I have?');

    expect(turn.offline, isTrue);
    expect(turn.snapshot!.recordedCashMinor, 255000);
    expect(turn.reply, isNot(contains('9,999')));
  });

  test('turns the domains sentence into an unconverted ZAR draft', () async {
    final orchestrator = CopilotOrchestrator(
      llm: const NullCopilotLlmClient(),
      finances: const _SnapshotPort(snapshot),
    );

    final turn = await orchestrator.handle(
      'I bought two domains at 50zar each',
    );

    expect(turn.drafts, hasLength(1));
    expect(turn.drafts.single.type, MoneyMovementType.expense);
    expect(turn.drafts.single.detectedCurrencyCode, 'ZAR');
    expect(turn.drafts.single.amountMinor, isNull);
    expect(turn.drafts.single.isComplete, isFalse);
    expect(turn.warning, isNotNull);
  });

  test(
    'prefills a pula unit price times quantity on a domain expense',
    () async {
      final orchestrator = CopilotOrchestrator(
        llm: const NullCopilotLlmClient(),
        finances: const _SnapshotPort(snapshot),
      );

      final turn = await orchestrator.handle(
        'I bought two domains at 50 pula each',
      );

      expect(turn.drafts, hasLength(1));
      expect(turn.drafts.single.item, 'domains');
      expect(turn.drafts.single.amountMinor, 10000);
      expect(turn.drafts.single.detectedCurrencyCode, 'BWP');
    },
  );

  test('extracts a pula sale and transport expense from one message', () async {
    final orchestrator = CopilotOrchestrator(
      llm: const NullCopilotLlmClient(),
      finances: const _SnapshotPort(snapshot),
    );

    final turn = await orchestrator.handle(
      'I sold two shirts for P300 and spent P80 on transport.',
    );

    expect(turn.drafts, hasLength(2));
    expect(turn.drafts[0].type, MoneyMovementType.sale);
    expect(turn.drafts[0].amountMinor, 30000);
    expect(turn.drafts[1].type, MoneyMovementType.expense);
    expect(turn.drafts[1].amountMinor, 8000);
    expect(turn.drafts[1].categoryCode, 'transport');
  });

  test(
    'unnamed amounts follow the profile currency on the orchestrator',
    () async {
      const zar = VerifiedFinancialSnapshot(
        currencyCode: 'ZAR',
        recordedCashMinor: 255000,
        recordedSalesMinor: 50000,
        recordedExpensesMinor: 10000,
        netOperatingResultMinor: 40000,
        periodLabel: 'October 2026',
        source: 'FinancialEngine',
      );
      final orchestrator = CopilotOrchestrator(
        llm: const NullCopilotLlmClient(),
        finances: const _SnapshotPort(zar),
      );

      final turn = await orchestrator.handle('I bought 2 domains at 50 each');

      expect(turn.drafts.single.amountMinor, 10000);
      expect(turn.drafts.single.detectedCurrencyCode, 'ZAR');
      expect(turn.drafts.single.businessCurrencyCode, 'ZAR');
      expect(turn.drafts.single.hasForeignCurrency, isFalse);
    },
  );

  test(
    'drafts a domain expense from record-this wording without asking again',
    () async {
      final orchestrator = CopilotOrchestrator(
        llm: const NullCopilotLlmClient(),
        finances: const _SnapshotPort(snapshot),
      );

      final turn = await orchestrator.handle(
        'hey I bought 2 domains at 50 each, can you please record this for me',
      );

      expect(turn.offer, CopilotOffer.none);
      expect(turn.drafts, hasLength(1));
      expect(turn.drafts.single.item, 'domains');
      expect(turn.drafts.single.amountMinor, 10000);
      expect(turn.drafts.single.paymentStatus, PaymentStatus.paid);
    },
  );

  test(
    'drafts omit the cash snapshot and still send the book currency',
    () async {
      final llm = ScriptedCopilotLlmClient(null);
      const zar = VerifiedFinancialSnapshot(
        currencyCode: 'ZAR',
        recordedCashMinor: 255000,
        recordedSalesMinor: 50000,
        recordedExpensesMinor: 10000,
        netOperatingResultMinor: 40000,
        periodLabel: 'October 2026',
        source: 'FinancialEngine',
      );
      final orchestrator = CopilotOrchestrator(
        llm: llm,
        finances: const _SnapshotPort(zar),
      );

      await orchestrator.handle('I bought 2 domains at 50 each');

      expect(llm.lastSnapshot, isNull);
      expect(llm.lastCurrencyCode, 'ZAR');
    },
  );

  test('malformed model JSON does not invent drafts', () async {
    final llm = ScriptedCopilotLlmClient(
      const CopilotLlmDraft(
        intent: 'drafts',
        transactionsJson: 'not json at all',
      ),
    );
    final orchestrator = CopilotOrchestrator(
      llm: llm,
      finances: const _SnapshotPort(snapshot),
    );

    final turn = await orchestrator.handle('record something');

    expect(turn.drafts, isEmpty);
  });
}
