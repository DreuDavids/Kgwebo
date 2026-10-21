import 'package:drift/drift.dart';

import '../../features/onboarding/domain/business_profile.dart';
import 'kgwebo_database.dart';

const confirmedSyncStatus = 'confirmed';

BusinessProfile businessProfileFromCached(CachedBusinessesData row) {
  if (row.ownerId.isEmpty) {
    throw StateError('Refusing a cache row with an empty owner id.');
  }
  if (row.syncStatus != confirmedSyncStatus) {
    throw StateError('Refusing an unverified business cache row.');
  }
  return BusinessProfile(
    id: row.remoteId,
    ownerId: row.ownerId,
    name: row.name,
    businessType: row.businessType,
    countryCode: row.countryCode,
    currencyCode: row.currencyCode,
    openingBalanceMinor: row.openingBalanceMinor,
    description: row.description,
    startedOn: row.startedOn == null ? null : DateTime.tryParse(row.startedOn!),
    contactPhone: row.contactPhone,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}

CachedBusinessesCompanion cachedCompanionFromProfile(BusinessProfile profile) {
  return CachedBusinessesCompanion.insert(
    remoteId: profile.id,
    ownerId: profile.ownerId,
    name: profile.name,
    businessType: profile.businessType,
    countryCode: profile.countryCode,
    currencyCode: profile.currencyCode,
    openingBalanceMinor: profile.openingBalanceMinor,
    description: Value(profile.description),
    startedOn: Value(_dateOnly(profile.startedOn)),
    contactPhone: Value(profile.contactPhone),
    createdAt: Value(profile.createdAt),
    updatedAt: Value(profile.updatedAt),
    cachedAt: DateTime.now().toUtc(),
    syncStatus: const Value(confirmedSyncStatus),
  );
}

String? _dateOnly(DateTime? value) {
  if (value == null) {
    return null;
  }
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
