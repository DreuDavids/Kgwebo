import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'kgwebo_database.g.dart';

/// Confirmed local copy of a remote business. One row per remote id, and at
/// most one row per owner.
class CachedBusinesses extends Table {
  TextColumn get remoteId => text()();
  TextColumn get ownerId => text().unique()();
  TextColumn get name => text()();
  TextColumn get businessType => text()();
  TextColumn get countryCode => text()();
  TextColumn get currencyCode => text()();
  IntColumn get openingBalanceMinor => integer()();
  TextColumn get description => text().nullable()();
  TextColumn get startedOn => text().nullable()();
  TextColumn get contactPhone => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get cachedAt => dateTime()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('confirmed'))();

  @override
  Set<Column<Object>> get primaryKey => {remoteId};
}

@DriftDatabase(tables: [CachedBusinesses])
class KgweboDatabase extends _$KgweboDatabase {
  KgweboDatabase() : super(_openConnection());

  KgweboDatabase.forExecutor(super.e);

  factory KgweboDatabase.memory() {
    return KgweboDatabase.forExecutor(NativeDatabase.memory());
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Schema v1 is the first Drift schema. Later phases append here.
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'kgwebo');
  }
}
