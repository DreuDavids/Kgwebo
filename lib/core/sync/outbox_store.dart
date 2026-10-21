import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../logging/app_logger.dart';
import '../persistence/kgwebo_database.dart';
import 'outbox_models.dart';

class OutboxStore {
  OutboxStore(this._db, {String Function()? idGenerator})
    : _idGenerator = idGenerator ?? const Uuid().v4;

  final KgweboDatabase _db;
  final String Function() _idGenerator;

  Future<OutboxOperation> enqueue({
    required String ownerId,
    required String businessId,
    required String operationType,
    required String payloadJson,
    required String idempotencyKey,
    DateTime? createdAt,
    String? dependsOnOperationId,
    String? operationId,
  }) async {
    if (ownerId.isEmpty || businessId.isEmpty || idempotencyKey.isEmpty) {
      throw const FormatException(
        'Outbox operations require owner, business and idempotency keys.',
      );
    }
    final existing = await findByIdempotency(
      ownerId: ownerId,
      businessId: businessId,
      idempotencyKey: idempotencyKey,
    );
    if (existing != null) {
      return existing;
    }
    final now = (createdAt ?? DateTime.now()).toUtc();
    final id = operationId ?? _idGenerator();
    await _db
        .into(_db.syncOutbox)
        .insert(
          SyncOutboxCompanion.insert(
            operationId: id,
            ownerId: ownerId,
            businessId: businessId,
            operationType: operationType,
            payloadJson: payloadJson,
            idempotencyKey: idempotencyKey,
            createdAt: now,
            state: OutboxState.pending.storageValue,
            dependsOnOperationId: Value(dependsOnOperationId),
          ),
        );
    final stored = await findById(id);
    if (stored == null) {
      throw StateError('Outbox insert did not persist.');
    }
    return stored;
  }

  Future<OutboxOperation?> findById(String operationId) async {
    if (operationId.isEmpty) {
      return null;
    }
    final row =
        await (_db.select(_db.syncOutbox)..where(
          (tbl) => tbl.operationId.equals(operationId),
        )).getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  Future<OutboxOperation?> findByIdempotency({
    required String ownerId,
    required String businessId,
    required String idempotencyKey,
  }) async {
    if (ownerId.isEmpty || businessId.isEmpty || idempotencyKey.isEmpty) {
      return null;
    }
    final row =
        await (_db.select(_db.syncOutbox)..where(
          (tbl) =>
              tbl.ownerId.equals(ownerId) &
              tbl.businessId.equals(businessId) &
              tbl.idempotencyKey.equals(idempotencyKey),
        )).getSingleOrNull();
    return row == null ? null : _owned(ownerId, businessId, _fromRow(row));
  }

  Future<List<OutboxOperation>> listOpen({
    required String ownerId,
    required String businessId,
  }) async {
    if (ownerId.isEmpty || businessId.isEmpty) {
      return const [];
    }
    final rows =
        await (_db.select(_db.syncOutbox)
              ..where(
                (tbl) =>
                    tbl.ownerId.equals(ownerId) &
                    tbl.businessId.equals(businessId) &
                    tbl.state.isNotValue(OutboxState.succeeded.storageValue),
              )
              ..orderBy([
                (tbl) => OrderingTerm.asc(tbl.createdAt),
                (tbl) => OrderingTerm.asc(tbl.operationId),
              ]))
            .get();
    return rows
        .map((row) => _owned(ownerId, businessId, _fromRow(row)))
        .toList();
  }

  Future<List<OutboxOperation>> listDue({
    required String ownerId,
    required String businessId,
    required DateTime now,
  }) async {
    if (ownerId.isEmpty || businessId.isEmpty) {
      return const [];
    }
    final instant = now.toUtc();
    final rows =
        await (_db.select(_db.syncOutbox)
              ..where(
                (tbl) =>
                    tbl.ownerId.equals(ownerId) &
                    tbl.businessId.equals(businessId) &
                    (tbl.state.equals(OutboxState.pending.storageValue) |
                        (tbl.state.equals(
                              OutboxState.retryableFailure.storageValue,
                            ) &
                            tbl.nextAttemptAt.isNotNull() &
                            tbl.nextAttemptAt.isSmallerOrEqualValue(instant))),
              )
              ..orderBy([
                (tbl) => OrderingTerm.asc(tbl.createdAt),
                (tbl) => OrderingTerm.asc(tbl.operationId),
              ]))
            .get();
    return rows
        .map((row) => _owned(ownerId, businessId, _fromRow(row)))
        .toList();
  }

  Future<List<OutboxOperation>> listForOwner(String ownerId) async {
    if (ownerId.isEmpty) {
      return const [];
    }
    final rows =
        await (_db.select(_db.syncOutbox)
              ..where((tbl) => tbl.ownerId.equals(ownerId))
              ..orderBy([
                (tbl) => OrderingTerm.asc(tbl.createdAt),
                (tbl) => OrderingTerm.asc(tbl.operationId),
              ]))
            .get();
    return rows.map(_fromRow).where((row) => row.ownerId == ownerId).toList();
  }

  Future<void> recoverInterrupted() async {
    await (_db.update(_db.syncOutbox)..where(
      (tbl) => tbl.state.equals(OutboxState.syncing.storageValue),
    )).write(
      SyncOutboxCompanion(
        state: Value(OutboxState.pending.storageValue),
        lastErrorCode: const Value('interrupted'),
        lastErrorMessage: const Value(
          'The previous sync attempt was interrupted. It will be retried.',
        ),
      ),
    );
  }

  Future<void> markSyncing(String operationId, DateTime now) async {
    await (_db.update(_db.syncOutbox)
      ..where((tbl) => tbl.operationId.equals(operationId))).write(
      SyncOutboxCompanion(
        state: Value(OutboxState.syncing.storageValue),
        lastAttemptAt: Value(now.toUtc()),
      ),
    );
  }

  Future<void> markSucceeded(String operationId, DateTime now) async {
    await (_db.update(_db.syncOutbox)
      ..where((tbl) => tbl.operationId.equals(operationId))).write(
      SyncOutboxCompanion(
        state: Value(OutboxState.succeeded.storageValue),
        succeededAt: Value(now.toUtc()),
        nextAttemptAt: const Value(null),
        lastErrorCode: const Value(null),
        lastErrorMessage: const Value(null),
      ),
    );
  }

  Future<int> markSucceededMatching({
    required String ownerId,
    required String businessId,
    required Iterable<String> idempotencyKeys,
    required DateTime now,
  }) async {
    final keys = {
      for (final key in idempotencyKeys)
        if (key.isNotEmpty) key,
    };
    if (ownerId.isEmpty || businessId.isEmpty || keys.isEmpty) {
      return 0;
    }
    var updated = 0;
    for (final key in keys) {
      updated += await (_db.update(_db.syncOutbox)..where(
        (tbl) =>
            tbl.ownerId.equals(ownerId) &
            tbl.businessId.equals(businessId) &
            tbl.idempotencyKey.equals(key) &
            tbl.state.isNotValue(OutboxState.succeeded.storageValue),
      )).write(
        SyncOutboxCompanion(
          state: Value(OutboxState.succeeded.storageValue),
          succeededAt: Value(now.toUtc()),
          nextAttemptAt: const Value(null),
          lastErrorCode: const Value(null),
          lastErrorMessage: const Value(null),
        ),
      );
    }
    return updated;
  }

  Future<void> markRetryable({
    required String operationId,
    required Object error,
    required DateTime now,
    required int attemptCount,
  }) async {
    final paused = attemptCount >= SyncPolicy.maxAutomaticAttempts;
    await (_db.update(_db.syncOutbox)
      ..where((tbl) => tbl.operationId.equals(operationId))).write(
      SyncOutboxCompanion(
        state: Value(OutboxState.retryableFailure.storageValue),
        attemptCount: Value(attemptCount),
        lastAttemptAt: Value(now.toUtc()),
        nextAttemptAt: Value(
          paused ? null : now.toUtc().add(SyncPolicy.backoffFor(attemptCount)),
        ),
        lastErrorCode: Value(SyncPolicy.safeCode(error)),
        lastErrorMessage: Value(SyncPolicy.safeMessage(error)),
      ),
    );
  }

  Future<void> markPermanent({
    required String operationId,
    required Object error,
    required DateTime now,
    required int attemptCount,
  }) async {
    await (_db.update(_db.syncOutbox)
      ..where((tbl) => tbl.operationId.equals(operationId))).write(
      SyncOutboxCompanion(
        state: Value(OutboxState.permanentFailure.storageValue),
        attemptCount: Value(attemptCount),
        lastAttemptAt: Value(now.toUtc()),
        nextAttemptAt: const Value(null),
        lastErrorCode: Value(SyncPolicy.safeCode(error)),
        lastErrorMessage: Value(SyncPolicy.safeMessage(error)),
      ),
    );
  }

  Future<void> requestManualRetry(String operationId, DateTime now) async {
    final current = await findById(operationId);
    if (current == null || current.state == OutboxState.succeeded) {
      return;
    }
    await (_db.update(_db.syncOutbox)
      ..where((tbl) => tbl.operationId.equals(operationId))).write(
      SyncOutboxCompanion(
        state: Value(OutboxState.pending.storageValue),
        nextAttemptAt: Value(now.toUtc()),
        lastErrorCode: const Value(null),
        lastErrorMessage: const Value(null),
      ),
    );
  }

  OutboxOperation _fromRow(SyncOutboxData row) {
    return OutboxOperation(
      operationId: row.operationId,
      ownerId: row.ownerId,
      businessId: row.businessId,
      operationType: row.operationType,
      payloadJson: row.payloadJson,
      idempotencyKey: row.idempotencyKey,
      createdAt: row.createdAt.toUtc(),
      state: OutboxStateCodec.fromStorage(row.state),
      attemptCount: row.attemptCount,
      lastAttemptAt: row.lastAttemptAt?.toUtc(),
      nextAttemptAt: row.nextAttemptAt?.toUtc(),
      lastErrorCode: row.lastErrorCode,
      lastErrorMessage:
          row.lastErrorMessage == null
              ? null
              : AppLogger.redactSecrets(row.lastErrorMessage!),
      dependsOnOperationId: row.dependsOnOperationId,
      succeededAt: row.succeededAt?.toUtc(),
    );
  }

  OutboxOperation _owned(
    String ownerId,
    String businessId,
    OutboxOperation operation,
  ) {
    if (!operation.belongsTo(ownerId: ownerId, businessId: businessId)) {
      throw StateError(
        'Outbox query returned a row for a different owner or business.',
      );
    }
    return operation;
  }
}
