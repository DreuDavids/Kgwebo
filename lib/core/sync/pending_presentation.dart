import '../../features/obligations/domain/business_obligation.dart';
import '../../features/transactions/domain/business_transaction.dart';
import '../finance/ledger_entry.dart';
import 'outbox_models.dart';

/// Confirmed rows win when the same idempotency key exists locally as
/// pending. Pending copies are display-only and never enter the engine.
List<BusinessTransaction> mergePendingTransactions({
  required List<BusinessTransaction> confirmed,
  required List<OutboxOperation> operations,
}) {
  final confirmedKeys = {
    for (final item in confirmed)
      if (item.idempotencyKey.isNotEmpty) item.idempotencyKey,
  };
  final pending = <BusinessTransaction>[];
  for (final operation in operations) {
    if (!operation.isCreateTransaction || !operation.state.isOpen) {
      continue;
    }
    if (confirmedKeys.contains(operation.idempotencyKey)) {
      continue;
    }
    pending.add(
      operation.asCreateTransaction().toPendingTransaction(
        operationId: operation.operationId,
        ownerId: operation.ownerId,
        businessId: operation.businessId,
        createdAt: operation.createdAt,
      ),
    );
  }
  final merged = [...pending, ...confirmed];
  merged.sort((a, b) {
    final byDate = b.occurredAt.compareTo(a.occurredAt);
    if (byDate != 0) {
      return byDate;
    }
    return b.id.compareTo(a.id);
  });
  return merged;
}

List<BusinessObligation> mergePendingObligations({
  required List<BusinessObligation> confirmed,
  required List<OutboxOperation> operations,
}) {
  final confirmedKeys = {
    for (final item in confirmed)
      if (item.idempotencyKey.isNotEmpty) item.idempotencyKey,
  };
  final pending = <BusinessObligation>[];
  for (final operation in operations) {
    if (!operation.isCreateObligation || !operation.state.isOpen) {
      continue;
    }
    if (confirmedKeys.contains(operation.idempotencyKey)) {
      continue;
    }
    pending.add(
      operation.asCreateObligation().toPendingObligation(
        operationId: operation.operationId,
        ownerId: operation.ownerId,
        businessId: operation.businessId,
        createdAt: operation.createdAt,
      ),
    );
  }
  final merged = [...pending, ...confirmed];
  merged.sort((a, b) {
    final byDate = a.dueOn.compareTo(b.dueOn);
    if (byDate != 0) {
      return byDate;
    }
    return a.id.compareTo(b.id);
  });
  return merged;
}

List<LedgerEntry> confirmedLedgerEntries(
  Iterable<BusinessTransaction> transactions,
) {
  return [
    for (final transaction in transactions)
      if (!transaction.pendingSync) transaction.toLedgerEntry(),
  ];
}

OutboxOperation? operationForPendingId({
  required String id,
  required List<OutboxOperation> operations,
}) {
  const prefix = 'pending:';
  if (!id.startsWith(prefix)) {
    return null;
  }
  final operationId = id.substring(prefix.length);
  for (final operation in operations) {
    if (operation.operationId == operationId) {
      return operation;
    }
  }
  return null;
}
