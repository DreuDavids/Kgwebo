import 'dart:async';
import 'dart:collection';

import '../../features/authentication/domain/auth_failure.dart';
import '../../features/obligations/application/obligation_repository.dart';
import '../../features/transactions/application/transaction_repository.dart';
import '../logging/app_logger.dart';
import '../persistence/obligation_cache.dart';
import '../persistence/transaction_cache.dart';
import 'outbox_models.dart';
import 'outbox_store.dart';

class SyncRunResult {
  const SyncRunResult({
    this.processed = 0,
    this.succeeded = 0,
    this.retryable = 0,
    this.permanent = 0,
    this.skipped = false,
    this.alreadyRunning = false,
  });

  final int processed;
  final int succeeded;
  final int retryable;
  final int permanent;
  final bool skipped;
  final bool alreadyRunning;
}

class _SessionSnapshot {
  const _SessionSnapshot({required this.ownerId, required this.businessId});

  final String ownerId;
  final String businessId;

  bool matches(String? ownerId, String? businessId) {
    return this.ownerId == ownerId && this.businessId == businessId;
  }
}

class _QueuedRun {
  const _QueuedRun({required this.ownerId, required this.businessId});

  final String ownerId;
  final String businessId;
}

class SyncCoordinator {
  SyncCoordinator({
    required OutboxStore outbox,
    required TransactionRepository remoteTransactions,
    required ObligationRepository remoteObligations,
    required TransactionCache transactionCache,
    required ObligationCache obligationCache,
    required String? Function() currentOwnerId,
    required String? Function() currentBusinessId,
    DateTime Function()? clock,
    void Function()? onChange,
    Duration? dispatchTimeout,
  }) : _outbox = outbox,
       _remoteTransactions = remoteTransactions,
       _remoteObligations = remoteObligations,
       _transactionCache = transactionCache,
       _obligationCache = obligationCache,
       _currentOwnerId = currentOwnerId,
       _currentBusinessId = currentBusinessId,
       _clock = clock ?? DateTime.now,
       _onChange = onChange,
       _dispatchTimeout = dispatchTimeout ?? SyncPolicy.dispatchTimeout;

  final OutboxStore _outbox;
  final TransactionRepository _remoteTransactions;
  final ObligationRepository _remoteObligations;
  final TransactionCache _transactionCache;
  final ObligationCache _obligationCache;
  final String? Function() _currentOwnerId;
  final String? Function() _currentBusinessId;
  final DateTime Function() _clock;
  final void Function()? _onChange;
  final Duration _dispatchTimeout;

  bool _running = false;
  final LinkedHashMap<String, _QueuedRun> _queued = LinkedHashMap();

  String _runKey(_QueuedRun run) => '${run.ownerId}\u0000${run.businessId}';

  DateTime _now() => _clock().toUtc();

  _SessionSnapshot? _liveSnapshot() {
    final ownerId = _currentOwnerId();
    final businessId = _currentBusinessId();
    if (ownerId == null ||
        ownerId.isEmpty ||
        businessId == null ||
        businessId.isEmpty) {
      return null;
    }
    return _SessionSnapshot(ownerId: ownerId, businessId: businessId);
  }

  bool _isLive(_SessionSnapshot snapshot) {
    final live = _liveSnapshot();
    return live != null && snapshot.matches(live.ownerId, live.businessId);
  }

  Future<SyncRunResult> process({
    required String ownerId,
    required String businessId,
  }) async {
    final requested = _QueuedRun(ownerId: ownerId, businessId: businessId);
    if (_running) {
      _queued[_runKey(requested)] = requested;
      return const SyncRunResult(alreadyRunning: true);
    }
    _running = true;
    late final SyncRunResult primary;
    try {
      primary = await _processSnapshot(requested);
      while (_queued.isNotEmpty) {
        final again = _queued.remove(_queued.keys.first)!;
        await _processSnapshot(again);
      }
    } finally {
      _running = false;
    }
    if (_queued.isNotEmpty) {
      final leftover = _queued.remove(_queued.keys.first)!;
      await process(ownerId: leftover.ownerId, businessId: leftover.businessId);
    }
    return primary;
  }

  Future<SyncRunResult> _processSnapshot(_QueuedRun requested) async {
    final live = _liveSnapshot();
    if (live == null) {
      return const SyncRunResult(skipped: true);
    }
    if (!live.matches(requested.ownerId, requested.businessId)) {
      AppLogger.warning(
        'Refusing to sync queued operations for a different owner or business.',
      );
      return const SyncRunResult(skipped: true);
    }
    final snapshot = live;
    var processed = 0;
    var succeeded = 0;
    var retryable = 0;
    var permanent = 0;
    await _outbox.recoverInterrupted(
      ownerId: snapshot.ownerId,
      businessId: snapshot.businessId,
    );
    final due = await _outbox.listDue(
      ownerId: snapshot.ownerId,
      businessId: snapshot.businessId,
      now: _now(),
    );
    for (final operation in due) {
      if (!_isLive(snapshot)) {
        return SyncRunResult(
          processed: processed,
          succeeded: succeeded,
          retryable: retryable,
          permanent: permanent,
          skipped: true,
        );
      }
      if (!operation.belongsTo(
        ownerId: snapshot.ownerId,
        businessId: snapshot.businessId,
      )) {
        continue;
      }
      if (operation.dependsOnOperationId != null) {
        final dependency = await _outbox.findById(
          operation.dependsOnOperationId!,
        );
        if (dependency == null || dependency.state != OutboxState.succeeded) {
          continue;
        }
      }
      final outcome = await _dispatch(operation: operation, snapshot: snapshot);
      switch (outcome) {
        case _DispatchOutcome.succeeded:
          processed += 1;
          succeeded += 1;
        case _DispatchOutcome.retryable:
          processed += 1;
          retryable += 1;
        case _DispatchOutcome.permanent:
          processed += 1;
          permanent += 1;
        case _DispatchOutcome.aborted:
          return SyncRunResult(
            processed: processed,
            succeeded: succeeded,
            retryable: retryable,
            permanent: permanent,
            skipped: true,
          );
        case _DispatchOutcome.skippedClaim:
          break;
      }
    }
    return SyncRunResult(
      processed: processed,
      succeeded: succeeded,
      retryable: retryable,
      permanent: permanent,
    );
  }

  Future<void> retry(String operationId) async {
    final live = _liveSnapshot();
    if (live == null) {
      return;
    }
    await _outbox.requestManualRetry(
      operationId: operationId,
      ownerId: live.ownerId,
      businessId: live.businessId,
      now: _now(),
    );
    _onChange?.call();
  }

  Future<_DispatchOutcome> _dispatch({
    required OutboxOperation operation,
    required _SessionSnapshot snapshot,
  }) async {
    if (!_isLive(snapshot)) {
      return _DispatchOutcome.aborted;
    }
    final claimed = await _outbox.tryClaimForSync(
      operationId: operation.operationId,
      ownerId: snapshot.ownerId,
      businessId: snapshot.businessId,
      now: _now(),
    );
    if (!claimed) {
      return _DispatchOutcome.skippedClaim;
    }
    _onChange?.call();
    if (!_isLive(snapshot)) {
      await _outbox.markInterrupted(
        operationId: operation.operationId,
        ownerId: snapshot.ownerId,
        businessId: snapshot.businessId,
      );
      return _DispatchOutcome.aborted;
    }
    final attempts = operation.attemptCount + 1;
    try {
      switch (operation.operationType) {
        case OutboxOperationTypes.createTransactionV1:
          await _pushTransaction(operation).timeout(_dispatchTimeout);
        case OutboxOperationTypes.createObligationV1:
          await _pushObligation(operation).timeout(_dispatchTimeout);
        default:
          throw const AuthFailure(
            'This queued change is not supported and was not sent.',
          );
      }
      await _outbox.markSucceeded(
        operationId: operation.operationId,
        ownerId: snapshot.ownerId,
        businessId: snapshot.businessId,
        now: _now(),
      );
      return _DispatchOutcome.succeeded;
    } on TimeoutException {
      if (!_isLive(snapshot)) {
        await _outbox.markInterrupted(
          operationId: operation.operationId,
          ownerId: snapshot.ownerId,
          businessId: snapshot.businessId,
        );
        return _DispatchOutcome.aborted;
      }
      await _outbox.markRetryable(
        operationId: operation.operationId,
        ownerId: snapshot.ownerId,
        businessId: snapshot.businessId,
        error: const AuthFailure.network(),
        now: _now(),
        attemptCount: attempts,
      );
      return _DispatchOutcome.retryable;
    } catch (error) {
      if (!_isLive(snapshot)) {
        await _outbox.markInterrupted(
          operationId: operation.operationId,
          ownerId: snapshot.ownerId,
          businessId: snapshot.businessId,
        );
        return _DispatchOutcome.aborted;
      }
      if (SyncPolicy.isRetryable(error)) {
        await _outbox.markRetryable(
          operationId: operation.operationId,
          ownerId: snapshot.ownerId,
          businessId: snapshot.businessId,
          error: error,
          now: _now(),
          attemptCount: attempts,
        );
        return _DispatchOutcome.retryable;
      }
      await _outbox.markPermanent(
        operationId: operation.operationId,
        ownerId: snapshot.ownerId,
        businessId: snapshot.businessId,
        error: error,
        now: _now(),
        attemptCount: attempts,
      );
      return _DispatchOutcome.permanent;
    }
  }

  Future<void> _pushTransaction(OutboxOperation operation) async {
    final payload = operation.asCreateTransaction();
    final saved = await _remoteTransactions.create(
      ownerId: operation.ownerId,
      businessId: operation.businessId,
      currencyCode: payload.currencyCode,
      draft: payload.toDraft(),
    );
    if (!saved.belongsTo(
      ownerId: operation.ownerId,
      businessId: operation.businessId,
    )) {
      throw const AuthFailure(
        'The server returned a transaction that does not belong to this account.',
      );
    }
    await _transactionCache.upsertConfirmed(saved);
  }

  Future<void> _pushObligation(OutboxOperation operation) async {
    final payload = operation.asCreateObligation();
    final saved = await _remoteObligations.create(
      ownerId: operation.ownerId,
      businessId: operation.businessId,
      currencyCode: payload.currencyCode,
      draft: payload.toDraft(),
    );
    if (!saved.belongsTo(
      ownerId: operation.ownerId,
      businessId: operation.businessId,
    )) {
      throw const AuthFailure(
        'The server returned a commitment that does not belong to this account.',
      );
    }
    await _obligationCache.upsertConfirmed(saved);
  }
}

enum _DispatchOutcome { succeeded, retryable, permanent, aborted, skippedClaim }
