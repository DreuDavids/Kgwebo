import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/ledger_entry.dart';
import 'package:kgwebo/features/copilot/application/copilot_commit.dart';
import 'package:kgwebo/features/copilot/domain/extracted_draft.dart';
import 'package:kgwebo/features/transactions/domain/payment_method.dart';

import '../../helpers/fake_transactions.dart';

void main() {
  ExtractedDraft completeExpense() {
    return ExtractedDraft(
      type: MoneyMovementType.expense,
      amountMinor: 8000,
      categoryCode: 'transport',
      paymentStatus: PaymentStatus.paid,
      occurredOn: DateTime(2026, 10, 25),
    );
  }

  test('does not write the ledger until confirm is called', () {
    final repository = FakeTransactionRepository();
    CopilotLedgerCommit(repository);
    expect(repository.createCalls, 0);
    expect(repository.items, isEmpty);
  });

  test('incomplete drafts cannot be saved', () async {
    final repository = FakeTransactionRepository();
    final commits = CopilotLedgerCommit(repository);

    expect(
      () => commits.confirm(
        draft: completeExpense().copyWith(clearAmount: true),
        paymentMethod: PaymentMethod.cash,
        ownerId: 'user-1',
        businessId: 'biz-1',
        currencyCode: 'BWP',
        occurredOn: DateTime(2026, 10, 25),
      ),
      throwsA(isA<StateError>()),
    );
    expect(repository.createCalls, 0);
  });

  test('foreign currency drafts are not converted into pula', () async {
    final repository = FakeTransactionRepository();
    final commits = CopilotLedgerCommit(repository);

    expect(
      () => commits.confirm(
        draft: const ExtractedDraft(
          type: MoneyMovementType.expense,
          amountMinor: 10000,
          categoryCode: 'fees',
          paymentStatus: PaymentStatus.paid,
          detectedCurrencyCode: 'ZAR',
        ),
        paymentMethod: PaymentMethod.cash,
        ownerId: 'user-1',
        businessId: 'biz-1',
        currencyCode: 'BWP',
        occurredOn: DateTime(2026, 10, 25),
      ),
      throwsA(isA<StateError>()),
    );
    expect(repository.createCalls, 0);
  });

  test(
    'explicit confirm writes one transaction through the repository',
    () async {
      final repository = FakeTransactionRepository();
      final commits = CopilotLedgerCommit(repository);

      final saved = await commits.confirm(
        draft: completeExpense(),
        paymentMethod: PaymentMethod.cash,
        ownerId: 'user-1',
        businessId: 'biz-1',
        currencyCode: 'BWP',
        occurredOn: DateTime(2026, 10, 25),
      );

      expect(repository.createCalls, 1);
      expect(repository.items, hasLength(1));
      expect(saved.amountMinor, 8000);
      expect(saved.type, MoneyMovementType.expense);
    },
  );

  test('two confirms do not reuse an idempotency key', () async {
    final repository = FakeTransactionRepository();
    final commits = CopilotLedgerCommit(repository);

    final first = await commits.confirm(
      draft: completeExpense(),
      paymentMethod: PaymentMethod.cash,
      ownerId: 'user-1',
      businessId: 'biz-1',
      currencyCode: 'BWP',
      occurredOn: DateTime(2026, 10, 25),
    );
    final second = await commits.confirm(
      draft: completeExpense(),
      paymentMethod: PaymentMethod.cash,
      ownerId: 'user-1',
      businessId: 'biz-1',
      currencyCode: 'BWP',
      occurredOn: DateTime(2026, 10, 25),
    );

    expect(first.idempotencyKey, isNot(second.idempotencyKey));
    expect(repository.createCalls, 2);
  });
}
