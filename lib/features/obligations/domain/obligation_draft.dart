import '../../../core/finance/cash_outlook.dart';

class ObligationDraft {
  const ObligationDraft({
    required this.title,
    required this.amountText,
    required this.dueOn,
    required this.category,
    required this.status,
    required this.idempotencyKey,
    this.notes = '',
    this.existingId,
  });

  final String title;
  final String amountText;
  final DateTime dueOn;
  final String category;
  final CommitmentStatus status;
  final String notes;
  final String idempotencyKey;
  final String? existingId;
}
