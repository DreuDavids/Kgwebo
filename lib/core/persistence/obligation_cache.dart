import 'package:drift/drift.dart';

import '../../features/obligations/domain/business_obligation.dart';
import 'business_mappers.dart';
import 'kgwebo_database.dart';
import 'obligation_mappers.dart';

class ObligationCache {
  ObligationCache(this._db);

  final KgweboDatabase _db;

  Future<List<BusinessObligation>> listConfirmed({
    required String ownerId,
    required String businessId,
  }) async {
    if (ownerId.isEmpty || businessId.isEmpty) {
      return const [];
    }
    final rows =
        await (_db.select(_db.cachedObligations)
              ..where(
                (tbl) =>
                    tbl.ownerId.equals(ownerId) &
                    tbl.businessId.equals(businessId) &
                    tbl.syncStatus.equals(confirmedSyncStatus),
              )
              ..orderBy([
                (tbl) => OrderingTerm.asc(tbl.dueOn),
                (tbl) => OrderingTerm.asc(tbl.remoteId),
              ]))
            .get();
    return rows.map(_owned(ownerId, businessId)).toList();
  }

  Future<BusinessObligation?> findConfirmed({
    required String ownerId,
    required String businessId,
    required String obligationId,
  }) async {
    if (ownerId.isEmpty || businessId.isEmpty || obligationId.isEmpty) {
      return null;
    }
    final row =
        await (_db.select(_db.cachedObligations)..where(
          (tbl) =>
              tbl.ownerId.equals(ownerId) &
              tbl.businessId.equals(businessId) &
              tbl.remoteId.equals(obligationId) &
              tbl.syncStatus.equals(confirmedSyncStatus),
        )).getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _owned(ownerId, businessId)(row);
  }

  Future<void> upsertConfirmed(BusinessObligation obligation) {
    return upsertAll([obligation]);
  }

  Future<void> upsertAll(List<BusinessObligation> obligations) async {
    if (obligations.isEmpty) {
      return;
    }
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.cachedObligations,
        obligations.map(cachedCompanionFromObligation).toList(),
      );
    });
  }

  Future<void> deleteConfirmed({
    required String ownerId,
    required String businessId,
    required String obligationId,
  }) async {
    if (ownerId.isEmpty || businessId.isEmpty || obligationId.isEmpty) {
      return;
    }
    await (_db.delete(_db.cachedObligations)..where(
      (tbl) =>
          tbl.ownerId.equals(ownerId) &
          tbl.businessId.equals(businessId) &
          tbl.remoteId.equals(obligationId),
    )).go();
  }

  Future<void> replaceForBusiness({
    required String ownerId,
    required String businessId,
    required List<BusinessObligation> obligations,
  }) async {
    if (ownerId.isEmpty || businessId.isEmpty) {
      return;
    }
    await _db.transaction(() async {
      await (_db.delete(_db.cachedObligations)..where(
        (tbl) =>
            tbl.ownerId.equals(ownerId) & tbl.businessId.equals(businessId),
      )).go();
      if (obligations.isNotEmpty) {
        await _db.batch((batch) {
          batch.insertAllOnConflictUpdate(
            _db.cachedObligations,
            obligations.map(cachedCompanionFromObligation).toList(),
          );
        });
      }
    });
  }

  Future<void> deleteForOwner(String ownerId) async {
    if (ownerId.isEmpty) {
      return;
    }
    await (_db.delete(_db.cachedObligations)
      ..where((tbl) => tbl.ownerId.equals(ownerId))).go();
  }

  BusinessObligation Function(CachedObligation row) _owned(
    String ownerId,
    String businessId,
  ) {
    return (row) {
      final obligation = businessObligationFromCached(row);
      if (!obligation.belongsTo(ownerId: ownerId, businessId: businessId)) {
        throw StateError(
          'Cache query returned a commitment for a different owner or business.',
        );
      }
      return obligation;
    };
  }
}
