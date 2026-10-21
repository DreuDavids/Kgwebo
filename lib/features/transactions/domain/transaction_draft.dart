import '../../../core/finance/ledger_entry.dart';
import 'payment_method.dart';

class TransactionDraft {
  const TransactionDraft({
    required this.type,
    required this.amountText,
    required this.occurredOn,
    required this.category,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.idempotencyKey,
    this.description = '',
    this.existingId,
  });

  final MoneyMovementType type;
  final String amountText;
  final DateTime occurredOn;
  final String category;
  final String description;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final String idempotencyKey;
  final String? existingId;

  bool get isEdit => existingId != null;
}
