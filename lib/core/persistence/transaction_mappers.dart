import 'package:drift/drift.dart';

import '../../features/transactions/domain/business_transaction.dart';
import '../../features/transactions/domain/payment_method.dart';
import 'business_mappers.dart';
import 'kgwebo_database.dart';

BusinessTransaction businessTransactionFromCached(CachedTransaction row) {
  if (row.ownerId.isEmpty || row.businessId.isEmpty) {
    throw StateError('Refusing a cache row without owner and business ids.');
  }
  if (row.syncStatus != confirmedSyncStatus) {
    throw StateError('Refusing an unverified transaction cache row.');
  }
  return BusinessTransaction(
    id: row.remoteId,
    businessId: row.businessId,
    ownerId: row.ownerId,
    createdBy: row.createdBy,
    idempotencyKey: row.idempotencyKey,
    type: BusinessTransaction.typeFromStorage(row.type),
    amountMinor: row.amountMinor,
    currencyCode: row.currencyCode,
    category: row.category,
    description: row.description,
    occurredAt: row.occurredAt.toUtc(),
    paymentMethod: PaymentMethodCodec.fromStorage(row.paymentMethod),
    paymentStatus: BusinessTransaction.statusFromStorage(row.paymentStatus),
    createdAt: row.createdAt.toUtc(),
    updatedAt: row.updatedAt.toUtc(),
  );
}

CachedTransactionsCompanion cachedCompanionFromTransaction(
  BusinessTransaction transaction,
) {
  return CachedTransactionsCompanion.insert(
    remoteId: transaction.id,
    ownerId: transaction.ownerId,
    businessId: transaction.businessId,
    createdBy: transaction.createdBy,
    idempotencyKey: transaction.idempotencyKey,
    type: BusinessTransaction.typeToStorage(transaction.type),
    amountMinor: transaction.amountMinor,
    currencyCode: transaction.currencyCode,
    category: transaction.category,
    description: Value(transaction.description),
    occurredAt: transaction.occurredAt.toUtc(),
    paymentMethod: transaction.paymentMethod.storageValue,
    paymentStatus: BusinessTransaction.statusToStorage(
      transaction.paymentStatus,
    ),
    createdAt: transaction.createdAt.toUtc(),
    updatedAt: transaction.updatedAt.toUtc(),
    cachedAt: DateTime.now().toUtc(),
    syncStatus: const Value(confirmedSyncStatus),
  );
}
