import 'package:drift/drift.dart';

import '../../features/transactions/domain/business_transaction.dart';
import '../../features/transactions/domain/transaction_query.dart';
import 'business_mappers.dart';
import 'kgwebo_database.dart';
import 'transaction_mappers.dart';

class TransactionCache {
  TransactionCache(this._db);

  final KgweboDatabase _db;

  Future<List<BusinessTransaction>> listConfirmed({
    required String ownerId,
    required String businessId,
    TransactionQuery query = const TransactionQuery(),
  }) async {
    if (ownerId.isEmpty || businessId.isEmpty) {
      return const [];
    }
    final statement =
        _db.select(_db.cachedTransactions)
          ..where(
            (tbl) =>
                tbl.ownerId.equals(ownerId) &
                tbl.businessId.equals(businessId) &
                tbl.syncStatus.equals(confirmedSyncStatus),
          )
          ..orderBy([
            (tbl) => OrderingTerm.desc(tbl.occurredAt),
            (tbl) => OrderingTerm.desc(tbl.remoteId),
          ])
          ..limit(query.limit + 1);

    final search = query.search?.trim();
    if (search != null && search.isNotEmpty) {
      final pattern = '%${_sanitizeLike(search)}%';
      statement.where(
        (tbl) => tbl.category.like(pattern) | tbl.description.like(pattern),
      );
    }
    if (query.type != null) {
      statement.where(
        (tbl) =>
            tbl.type.equals(BusinessTransaction.typeToStorage(query.type!)),
      );
    }
    final category = query.category?.trim();
    if (category != null && category.isNotEmpty) {
      statement.where((tbl) => tbl.category.equals(category));
    }
    final period = query.period;
    if (period != null) {
      statement.where(
        (tbl) =>
            tbl.occurredAt.isBiggerOrEqualValue(period.startInclusive) &
            tbl.occurredAt.isSmallerThanValue(period.endExclusive),
      );
    }
    final cursorAt = query.beforeOccurredAt;
    final cursorId = query.beforeId;
    if (cursorAt != null && cursorId != null) {
      statement.where(
        (tbl) =>
            tbl.occurredAt.isSmallerThanValue(cursorAt) |
            (tbl.occurredAt.equals(cursorAt) &
                tbl.remoteId.isSmallerThanValue(cursorId)),
      );
    }

    final rows = await statement.get();
    return rows.map(_owned(ownerId, businessId)).toList();
  }

  Future<BusinessTransaction?> findConfirmed({
    required String ownerId,
    required String businessId,
    required String transactionId,
  }) async {
    if (ownerId.isEmpty || businessId.isEmpty || transactionId.isEmpty) {
      return null;
    }
    final row =
        await (_db.select(_db.cachedTransactions)..where(
          (tbl) =>
              tbl.ownerId.equals(ownerId) &
              tbl.businessId.equals(businessId) &
              tbl.remoteId.equals(transactionId) &
              tbl.syncStatus.equals(confirmedSyncStatus),
        )).getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _owned(ownerId, businessId)(row);
  }

  Future<void> upsertConfirmed(BusinessTransaction transaction) {
    return upsertAll([transaction]);
  }

  Future<void> upsertAll(List<BusinessTransaction> transactions) async {
    if (transactions.isEmpty) {
      return;
    }
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.cachedTransactions,
        transactions.map(cachedCompanionFromTransaction).toList(),
      );
    });
  }

  Future<void> deleteConfirmed({
    required String ownerId,
    required String businessId,
    required String transactionId,
  }) async {
    if (ownerId.isEmpty || businessId.isEmpty || transactionId.isEmpty) {
      return;
    }
    await (_db.delete(_db.cachedTransactions)..where(
      (tbl) =>
          tbl.ownerId.equals(ownerId) &
          tbl.businessId.equals(businessId) &
          tbl.remoteId.equals(transactionId),
    )).go();
  }

  Future<void> replaceForBusiness({
    required String ownerId,
    required String businessId,
    required List<BusinessTransaction> transactions,
  }) async {
    if (ownerId.isEmpty || businessId.isEmpty) {
      return;
    }
    await _db.transaction(() async {
      await (_db.delete(_db.cachedTransactions)..where(
        (tbl) =>
            tbl.ownerId.equals(ownerId) & tbl.businessId.equals(businessId),
      )).go();
      if (transactions.isNotEmpty) {
        await _db.batch((batch) {
          batch.insertAllOnConflictUpdate(
            _db.cachedTransactions,
            transactions.map(cachedCompanionFromTransaction).toList(),
          );
        });
      }
    });
  }

  Future<void> deleteForOwner(String ownerId) async {
    if (ownerId.isEmpty) {
      return;
    }
    await (_db.delete(_db.cachedTransactions)
      ..where((tbl) => tbl.ownerId.equals(ownerId))).go();
  }

  BusinessTransaction Function(CachedTransaction row) _owned(
    String ownerId,
    String businessId,
  ) {
    return (row) {
      final transaction = businessTransactionFromCached(row);
      if (!transaction.belongsTo(ownerId: ownerId, businessId: businessId)) {
        throw StateError(
          'Cache query returned a transaction for a different owner or business.',
        );
      }
      return transaction;
    };
  }

  String _sanitizeLike(String raw) {
    return raw.replaceAll('%', '').replaceAll('_', '');
  }
}
