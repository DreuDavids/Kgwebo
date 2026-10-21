import 'package:drift/drift.dart';

import '../../features/onboarding/domain/business_profile.dart';
import 'business_mappers.dart';
import 'kgwebo_database.dart';

class BusinessCache {
  BusinessCache(this._db);

  final KgweboDatabase _db;

  Future<BusinessProfile?> findConfirmedForOwner(String ownerId) async {
    if (ownerId.isEmpty) {
      return null;
    }
    final row =
        await (_db.select(_db.cachedBusinesses)..where(
          (tbl) =>
              tbl.ownerId.equals(ownerId) &
              tbl.syncStatus.equals(confirmedSyncStatus),
        )).getSingleOrNull();
    if (row == null) {
      return null;
    }
    if (row.ownerId != ownerId) {
      throw StateError('Cache query returned a row for a different owner.');
    }
    return businessProfileFromCached(row);
  }

  Future<void> upsertConfirmed(BusinessProfile profile) async {
    if (profile.ownerId.isEmpty || profile.id.isEmpty) {
      throw ArgumentError('Cannot cache a business without id and owner.');
    }
    await _db.transaction(() async {
      await (_db.delete(_db.cachedBusinesses)..where(
        (tbl) =>
            tbl.ownerId.equals(profile.ownerId) &
            tbl.remoteId.equals(profile.id).not(),
      )).go();
      await _db
          .into(_db.cachedBusinesses)
          .insertOnConflictUpdate(cachedCompanionFromProfile(profile));
    });
  }

  Future<void> deleteForOwner(String ownerId) async {
    if (ownerId.isEmpty) {
      return;
    }
    await (_db.delete(_db.cachedBusinesses)
      ..where((tbl) => tbl.ownerId.equals(ownerId))).go();
  }
}
