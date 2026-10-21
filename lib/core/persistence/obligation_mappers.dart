import 'package:drift/drift.dart';

import '../../features/obligations/domain/business_obligation.dart';
import 'business_mappers.dart';
import 'kgwebo_database.dart';

BusinessObligation businessObligationFromCached(CachedObligation row) {
  if (row.ownerId.isEmpty || row.businessId.isEmpty) {
    throw StateError('Refusing a cache row without owner and business ids.');
  }
  if (row.syncStatus != confirmedSyncStatus) {
    throw StateError('Refusing an unverified obligation cache row.');
  }
  return BusinessObligation(
    id: row.remoteId,
    businessId: row.businessId,
    ownerId: row.ownerId,
    createdBy: row.createdBy,
    idempotencyKey: row.idempotencyKey,
    title: row.title,
    amountMinor: row.amountMinor,
    currencyCode: row.currencyCode,
    dueOn: DateTime(row.dueOn.year, row.dueOn.month, row.dueOn.day),
    status: BusinessObligation.statusFromStorage(row.status),
    category: row.category,
    notes: row.notes,
    recordedTransactionId: row.recordedTransactionId,
    createdAt: row.createdAt.toUtc(),
    updatedAt: row.updatedAt.toUtc(),
  );
}

CachedObligationsCompanion cachedCompanionFromObligation(
  BusinessObligation obligation,
) {
  return CachedObligationsCompanion.insert(
    remoteId: obligation.id,
    ownerId: obligation.ownerId,
    businessId: obligation.businessId,
    createdBy: obligation.createdBy,
    idempotencyKey: obligation.idempotencyKey,
    title: obligation.title,
    amountMinor: obligation.amountMinor,
    currencyCode: obligation.currencyCode,
    dueOn: DateTime.utc(
      obligation.dueOn.year,
      obligation.dueOn.month,
      obligation.dueOn.day,
    ),
    status: BusinessObligation.statusToStorage(obligation.status),
    category: obligation.category,
    notes: Value(obligation.notes),
    recordedTransactionId: Value(obligation.recordedTransactionId),
    createdAt: obligation.createdAt.toUtc(),
    updatedAt: obligation.updatedAt.toUtc(),
    cachedAt: DateTime.now().toUtc(),
    syncStatus: const Value(confirmedSyncStatus),
  );
}
