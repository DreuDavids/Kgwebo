import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/cash_outlook.dart';
import 'package:kgwebo/features/obligations/application/obligation_validators.dart';
import 'package:kgwebo/features/obligations/domain/obligation_draft.dart';

ObligationDraft draft({
  String title = 'Shop rent',
  String amount = '800.00',
  String category = 'rent',
  String notes = '',
}) {
  return ObligationDraft(
    title: title,
    amountText: amount,
    dueOn: DateTime(2026, 10, 28),
    category: category,
    status: CommitmentStatus.unpaid,
    notes: notes,
    idempotencyKey: '11111111-1111-1111-1111-111111111111',
  );
}

void main() {
  test('accepts a valid rent commitment', () {
    expect(validateObligationDraft(draft()).hasErrors, isFalse);
  });

  test('rejects an empty title and a zero amount', () {
    final errors = validateObligationDraft(draft(title: '  ', amount: '0'));
    expect(errors.title, isNotNull);
    expect(errors.amount, isNotNull);
  });

  test('rejects an unknown category and a long note', () {
    final errors = validateObligationDraft(
      draft(category: 'mystery', notes: 'x' * 501),
    );
    expect(errors.category, isNotNull);
    expect(errors.notes, isNotNull);
  });
}
