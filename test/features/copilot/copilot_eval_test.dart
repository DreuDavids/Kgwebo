import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/ledger_entry.dart';
import 'package:kgwebo/features/copilot/application/copilot_book.dart';
import 'package:kgwebo/features/copilot/application/copilot_follow_up.dart';
import 'package:kgwebo/features/copilot/application/copilot_grounding.dart';
import 'package:kgwebo/features/copilot/application/copilot_intent.dart';
import 'package:kgwebo/features/copilot/application/copilot_llm_client.dart';
import 'package:kgwebo/features/copilot/application/copilot_orchestrator.dart';
import 'package:kgwebo/features/copilot/application/financial_read_port.dart';
import 'package:kgwebo/features/copilot/application/heuristic_extractor.dart';
import 'package:kgwebo/features/copilot/domain/copilot_session.dart';
import 'package:kgwebo/features/copilot/domain/copilot_turn.dart';

class _SnapshotPort implements FinancialReadPort {
  const _SnapshotPort(this.snapshot);

  final VerifiedFinancialSnapshot? snapshot;

  @override
  Future<VerifiedFinancialSnapshot?> currentSnapshot() async => snapshot;
}

class _BookPort implements CopilotBookPort {
  const _BookPort(this.book);

  final CopilotBook book;

  @override
  Future<CopilotBook> currentBook() async => book;
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

  final book = CopilotBook(
    snapshot: snapshot,
    overdueBills: [
      CopilotBillFact(
        title: 'Shop rent',
        amountMinor: 80000,
        dueOn: DateTime(2026, 10, 1),
        overdue: true,
      ),
    ],
    recent: [
      CopilotRecentFact(
        type: MoneyMovementType.sale,
        amountMinor: 30000,
        occurredAt: DateTime(2026, 10, 21),
        description: 'shirts',
      ),
    ],
    products: const [
      CopilotStockFact(
        name: 'Fat cakes',
        sellingPriceMinor: 1000,
        needsRestock: true,
      ),
    ],
  );

  CopilotOrchestrator orch() {
    return CopilotOrchestrator(
      llm: const NullCopilotLlmClient(),
      finances: const _SnapshotPort(snapshot),
      book: _BookPort(book),
    );
  }

  test(
    'golden utterances keep drafts, cash, bills and refusals stable',
    () async {
      final cases = <_EvalCase>[
        _EvalCase(
          'hey I bought 2 domains at 50 each, record this',
          expectDraft: true,
          amount: 10000,
          type: MoneyMovementType.expense,
        ),
        _EvalCase(
          'I sold two shirts for P300 and spent P80 on transport',
          expectDraft: true,
          amount: 30000,
        ),
        _EvalCase(
          'I sold two fat cakes at 10 each',
          expectDraft: true,
          amount: 2000,
          item: 'fat cakes',
        ),
        _EvalCase(
          'I bought airtime 50',
          expectDraft: true,
          amount: 5000,
          item: 'airtime',
        ),
        _EvalCase(
          'I sold two shirts for P300 on credit',
          expectDraft: true,
          unpaid: true,
        ),
        _EvalCase(
          'Ke rekisitse dihempe di le 2 ka P150 each',
          expectDraft: true,
          amount: 30000,
        ),
        _EvalCase(
          'I took 200 for myself',
          expectDraft: true,
          type: MoneyMovementType.ownerWithdrawal,
          amount: 20000,
        ),
        _EvalCase(
          'I bought two domains at 50zar each',
          expectDraft: true,
          foreign: true,
        ),
        _EvalCase('How much cash do I have?', expectCash: true),
        _EvalCase('ke na le madi a kae?', expectCash: true),
        _EvalCase('What do I owe this week?', expectBills: true),
        _EvalCase('What stock needs restocking?', expectStock: true),
        _EvalCase('Open last sale', expectRecent: true),
        _EvalCase('What should I watch?', expectWatch: true),
        _EvalCase('I want to record a sale', expectOffer: true),
        _EvalCase(
          'You should buy Bitcoin with my cash',
          expectRefuseInvented: true,
        ),
      ];

      for (final item in cases) {
        final turn = await orch().handle(item.prompt);
        if (item.expectDraft) {
          expect(turn.drafts, isNotEmpty, reason: item.prompt);
          if (item.amount != null) {
            expect(
              turn.drafts.first.amountMinor,
              item.amount,
              reason: item.prompt,
            );
          }
          if (item.type != null) {
            expect(turn.drafts.first.type, item.type, reason: item.prompt);
          }
          if (item.item != null) {
            expect(turn.drafts.first.item, item.item, reason: item.prompt);
          }
          if (item.unpaid) {
            expect(
              turn.drafts.first.paymentStatus,
              PaymentStatus.unpaid,
              reason: item.prompt,
            );
          }
          if (item.foreign) {
            expect(
              turn.drafts.first.hasForeignCurrency,
              isTrue,
              reason: item.prompt,
            );
          }
        }
        if (item.expectCash) {
          expect(
            turn.source,
            CopilotSource.verifiedRecords,
            reason: item.prompt,
          );
          expect(turn.reply, contains('2,550.00'), reason: item.prompt);
        }
        if (item.expectBills) {
          expect(
            turn.reply.toLowerCase(),
            contains('shop rent'),
            reason: item.prompt,
          );
        }
        if (item.expectStock) {
          expect(turn.reply, contains('Fat cakes'), reason: item.prompt);
        }
        if (item.expectRecent) {
          expect(
            turn.reply.toLowerCase(),
            contains('shirts'),
            reason: item.prompt,
          );
        }
        if (item.expectWatch) {
          expect(
            turn.reply.toLowerCase(),
            contains('recommendation'),
            reason: item.prompt,
          );
        }
        if (item.expectOffer) {
          expect(turn.offer, CopilotOffer.recordSale, reason: item.prompt);
        }
        if (item.expectRefuseInvented) {
          expect(turn.reply, isNot(contains('Bitcoin')), reason: item.prompt);
          expect(turn.reply, isNot(contains('9,999')), reason: item.prompt);
        }
      }
    },
  );

  test('follow-up corrections reuse the last draft', () {
    final first =
        extractHeuristicDrafts('I bought 2 domains at 50 each').single;
    final next = CopilotFollowUp.apply(
      userText: 'make it unpaid',
      lastDrafts: [first],
    );
    expect(next!.single.paymentStatus, PaymentStatus.unpaid);
    expect(next.single.amountMinor, 10000);
  });

  test('after one confirm, incomplete record requests skip the fork', () {
    final turn = groundCopilotTurn(
      userText: 'I want to record a sale',
      snapshot: snapshot,
      session: const CopilotSession(hasConfirmedOnce: true),
    );
    expect(turn.offer, CopilotOffer.none);
    expect(turn.reply.toLowerCase(), contains('pula'));
  });

  test('draft questions do not send cash snapshot to the model', () async {
    final llm = ScriptedCopilotLlmClient(null);
    final orchestrator = CopilotOrchestrator(
      llm: llm,
      finances: const _SnapshotPort(snapshot),
      book: _BookPort(book),
    );

    await orchestrator.handle('I bought airtime 50');

    expect(llm.lastSnapshot, isNull);
  });

  test('cash questions still classify as finances', () {
    expect(
      classifyCopilotIntent('How much cash do I have?'),
      CopilotIntentKind.finances,
    );
  });
}

class _EvalCase {
  const _EvalCase(
    this.prompt, {
    this.expectDraft = false,
    this.expectCash = false,
    this.expectBills = false,
    this.expectStock = false,
    this.expectRecent = false,
    this.expectWatch = false,
    this.expectOffer = false,
    this.expectRefuseInvented = false,
    this.amount,
    this.type,
    this.item,
    this.unpaid = false,
    this.foreign = false,
  });

  final String prompt;
  final bool expectDraft;
  final bool expectCash;
  final bool expectBills;
  final bool expectStock;
  final bool expectRecent;
  final bool expectWatch;
  final bool expectOffer;
  final bool expectRefuseInvented;
  final int? amount;
  final MoneyMovementType? type;
  final String? item;
  final bool unpaid;
  final bool foreign;
}
