import '../../../core/finance/ledger_entry.dart';
import '../../../core/money/money_parser.dart';
import '../domain/transaction_categories.dart';
import '../domain/transaction_draft.dart';

class TransactionFieldErrors {
  const TransactionFieldErrors({
    this.amount,
    this.category,
    this.description,
    this.date,
  });

  final String? amount;
  final String? category;
  final String? description;
  final String? date;

  bool get hasErrors =>
      amount != null || category != null || description != null || date != null;
}

TransactionFieldErrors validateTransactionDraft(TransactionDraft draft) {
  final amount = tryParseMinorUnits(draft.amountText);
  return TransactionFieldErrors(
    amount:
        amount == null ? 'Enter a positive amount, for example 50.00.' : null,
    category:
        TransactionCategories.isAllowed(draft.type, draft.category)
            ? null
            : 'Choose a category.',
    description:
        draft.description.trim().length > 500
            ? 'Keep the note under 500 characters.'
            : null,
    date: null,
  );
}

String titleForType(MoneyMovementType type) {
  return switch (type) {
    MoneyMovementType.sale => 'Record a sale',
    MoneyMovementType.expense => 'Record an expense',
    MoneyMovementType.refund => 'Record a refund',
    MoneyMovementType.ownerContribution => 'Money you put in',
    MoneyMovementType.ownerWithdrawal => 'Money you took out',
  };
}

String editTitleForType(MoneyMovementType type) {
  return switch (type) {
    MoneyMovementType.sale => 'Edit sale',
    MoneyMovementType.expense => 'Edit expense',
    MoneyMovementType.refund => 'Edit refund',
    MoneyMovementType.ownerContribution => 'Edit money you put in',
    MoneyMovementType.ownerWithdrawal => 'Edit money you took out',
  };
}
