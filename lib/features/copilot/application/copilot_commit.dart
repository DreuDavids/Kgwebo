import 'package:uuid/uuid.dart';

import '../../../core/finance/ledger_entry.dart';
import '../../../core/money/minor_units.dart';
import '../../transactions/application/transaction_repository.dart';
import '../../transactions/application/transaction_validators.dart';
import '../../transactions/domain/business_transaction.dart';
import '../../transactions/domain/payment_method.dart';
import '../../transactions/domain/transaction_draft.dart';
import '../domain/extracted_draft.dart';

class CopilotLedgerCommit {
  CopilotLedgerCommit(this._transactions, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final TransactionRepository _transactions;
  final Uuid _uuid;

  Future<BusinessTransaction> confirm({
    required ExtractedDraft draft,
    required PaymentMethod paymentMethod,
    required String ownerId,
    required String businessId,
    required String currencyCode,
    required DateTime occurredOn,
  }) async {
    var ready = draft;
    if (ready.occurredOn == null) {
      ready = ready.copyWith(occurredOn: occurredOn);
    }
    if (!ready.isComplete) {
      throw StateError(
        'A suggested transaction cannot be saved until missing fields are filled.',
      );
    }
    final named = ready.detectedCurrencyCode;
    if (named != null && named.toUpperCase() != currencyCode.toUpperCase()) {
      throw StateError(
        'Enter the amount in $currencyCode before saving. Named $named is not converted.',
      );
    }
    final txnDraft = TransactionDraft(
      type: ready.type,
      amountText: MinorUnits.format(ready.amountMinor!, group: false),
      occurredOn: ready.occurredOn!,
      category: ready.categoryCode!,
      description: [
        if (ready.item != null) ready.item!,
        if (ready.note != null) ready.note!,
      ].join(' · '),
      paymentMethod: paymentMethod,
      paymentStatus: ready.paymentStatus ?? PaymentStatus.paid,
      idempotencyKey: _uuid.v4(),
    );
    final errors = validateTransactionDraft(txnDraft);
    if (errors.hasErrors) {
      throw StateError(errors.amount ?? errors.category ?? 'Invalid draft.');
    }
    return _transactions.create(
      ownerId: ownerId,
      businessId: businessId,
      currencyCode: currencyCode,
      draft: txnDraft,
    );
  }
}
