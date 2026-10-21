import '../../../core/money/money_parser.dart';
import '../domain/business_obligation.dart';
import '../domain/obligation_draft.dart';

Map<String, dynamic> obligationWriteMap({
  required String businessId,
  required String currencyCode,
  required ObligationDraft draft,
}) {
  final amount = tryParseMinorUnits(draft.amountText);
  if (amount == null) {
    throw FormatException('Invalid amount', draft.amountText);
  }
  final notes = draft.notes.trim();
  final due = DateTime(draft.dueOn.year, draft.dueOn.month, draft.dueOn.day);
  return {
    'business_id': businessId,
    'idempotency_key': draft.idempotencyKey,
    'title': draft.title.trim(),
    'amount_minor': amount,
    'currency_code': currencyCode,
    'due_date':
        '${due.year.toString().padLeft(4, '0')}-${due.month.toString().padLeft(2, '0')}-${due.day.toString().padLeft(2, '0')}',
    'status': BusinessObligation.statusToStorage(draft.status),
    'category': draft.category.trim(),
    'notes': notes.isEmpty ? null : notes,
  };
}
