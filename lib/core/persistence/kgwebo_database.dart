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

/// Confirmed local copy of a remote money movement. Scoped by owner and
/// business so account switching cannot leak rows.
class CachedTransactions extends Table {
  TextColumn get remoteId => text()();
  TextColumn get ownerId => text()();
  TextColumn get businessId => text()();
  TextColumn get createdBy => text()();
  TextColumn get idempotencyKey => text()();
  TextColumn get type => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get currencyCode => text()();
  TextColumn get category => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get paymentMethod => text()();
  TextColumn get paymentStatus => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get cachedAt => dateTime()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('confirmed'))();

  @override
  Set<Column<Object>> get primaryKey => {remoteId};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {ownerId, businessId, idempotencyKey},
  ];
}

/// Confirmed local copy of a remote upcoming commitment. Scoped by owner
/// and business so account switching cannot leak rows.
class CachedObligations extends Table {
  TextColumn get remoteId => text()();
  TextColumn get ownerId => text()();
  TextColumn get businessId => text()();
  TextColumn get createdBy => text()();
  TextColumn get idempotencyKey => text()();
  TextColumn get title => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get currencyCode => text()();
  DateTimeColumn get dueOn => dateTime()();
  TextColumn get status => text()();
  TextColumn get category => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get recordedTransactionId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get cachedAt => dateTime()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('confirmed'))();

  @override
  Set<Column<Object>> get primaryKey => {remoteId};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {ownerId, businessId, idempotencyKey},
  ];
}

@DriftDatabase(
  tables: [CachedBusinesses, CachedTransactions, CachedObligations],
)
class KgweboDatabase extends _$KgweboDatabase {
  KgweboDatabase() : super(_openConnection());

  KgweboDatabase.forExecutor(super.e);

  factory KgweboDatabase.memory() {
    return KgweboDatabase.forExecutor(NativeDatabase.memory());
  }

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(cachedTransactions);
        }
        if (from < 3) {
          await m.createTable(cachedObligations);
        }
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'kgwebo');
  }
}
