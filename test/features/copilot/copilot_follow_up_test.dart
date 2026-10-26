import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/ledger_entry.dart';
import 'package:kgwebo/features/copilot/application/copilot_follow_up.dart';
import 'package:kgwebo/features/copilot/domain/extracted_draft.dart';

void main() {
  const draft = ExtractedDraft(
    type: MoneyMovementType.expense,
    amountMinor: 10000,
    item: 'domains',
    categoryCode: 'fees',
    paymentStatus: PaymentStatus.paid,
  );

  test('marks the last draft unpaid without starting over', () {
    final next = CopilotFollowUp.apply(
      userText: 'make it unpaid',
      lastDrafts: const [draft],
    );

    expect(next, isNotNull);
    expect(next!.single.amountMinor, 10000);
    expect(next.single.item, 'domains');
    expect(next.single.paymentStatus, PaymentStatus.unpaid);
  });

  test('corrects the last draft amount from it was 80', () {
    final next = CopilotFollowUp.apply(
      userText: 'no, it was 80',
      lastDrafts: const [draft],
    );

    expect(next!.single.amountMinor, 8000);
    expect(next.single.item, 'domains');
  });

  test('does not treat a new purchase as a follow-up', () {
    final next = CopilotFollowUp.apply(
      userText: 'I bought airtime 50',
      lastDrafts: const [draft],
    );

    expect(next, isNull);
  });
}
