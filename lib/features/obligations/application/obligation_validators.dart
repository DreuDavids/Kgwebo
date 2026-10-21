import '../../../core/money/money_parser.dart';
import '../domain/obligation_categories.dart';
import '../domain/obligation_draft.dart';

class ObligationFieldErrors {
  const ObligationFieldErrors({
    this.title,
    this.amount,
    this.category,
    this.dueOn,
    this.notes,
  });

  final String? title;
  final String? amount;
  final String? category;
  final String? dueOn;
  final String? notes;

  bool get hasErrors =>
      title != null ||
      amount != null ||
      category != null ||
      dueOn != null ||
      notes != null;
}

ObligationFieldErrors validateObligationDraft(ObligationDraft draft) {
  final title = draft.title.trim();
  final amount = tryParseMinorUnits(draft.amountText);
  return ObligationFieldErrors(
    title:
        title.isEmpty || title.length > 120
            ? 'Enter a short description, up to 120 characters.'
            : null,
    amount:
        amount == null
            ? 'Enter a positive amount in pula and thebe, for example 50.00.'
            : null,
    category:
        ObligationCategories.isAllowed(draft.category)
            ? null
            : 'Choose a category.',
    dueOn: null,
    notes:
        draft.notes.trim().length > 500
            ? 'Keep the note under 500 characters.'
            : null,
  );
}
