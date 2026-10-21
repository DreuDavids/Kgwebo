import '../../../core/finance/business_calendar.dart';
import '../../../core/money/money_parser.dart';
import '../domain/business_transaction.dart';
import '../domain/payment_method.dart';
import '../domain/transaction_draft.dart';

Map<String, dynamic> transactionWriteMap({
  required String businessId,
  required String currencyCode,
  required TransactionDraft draft,
}) {
  final amount = tryParseMinorUnits(draft.amountText);
  if (amount == null) {
    throw FormatException('Invalid amount', draft.amountText);
  }
  final description = draft.description.trim();
  return {
    'business_id': businessId,
    'idempotency_key': draft.idempotencyKey,
    'type': BusinessTransaction.typeToStorage(draft.type),
    'amount_minor': amount,
    'currency_code': currencyCode,
    'category': draft.category.trim(),
    'description': description.isEmpty ? null : description,
    'occurred_at':
        BusinessCalendar.utcFromGaborone(
          year: draft.occurredOn.year,
          month: draft.occurredOn.month,
          day: draft.occurredOn.day,
        ).toIso8601String(),
    'payment_method': draft.paymentMethod.storageValue,
    'payment_status': BusinessTransaction.statusToStorage(draft.paymentStatus),
  };
}
