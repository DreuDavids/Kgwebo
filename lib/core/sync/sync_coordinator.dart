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

class SyncCoordinator {
  SyncCoordinator({
    required OutboxStore outbox,
    required TransactionRepository remoteTransactions,
    required ObligationRepository remoteObligations,
    required TransactionCache transactionCache,
    required ObligationCache obligationCache,
    required String? Function() currentOwnerId,
    DateTime Function()? clock,
    void Function()? onChange,
  }) : _outbox = outbox,
       _remoteTransactions = remoteTransactions,
       _remoteObligations = remoteObligations,
       _transactionCache = transactionCache,
       _obligationCache = obligationCache,
       _currentOwnerId = currentOwnerId,
       _clock = clock ?? DateTime.now,
       _onChange = onChange;

  final OutboxStore _outbox;
  final TransactionRepository _remoteTransactions;
  final ObligationRepository _remoteObligations;
  final TransactionCache _transactionCache;
  final ObligationCache _obligationCache;
  final String? Function() _currentOwnerId;
  final DateTime Function() _clock;
  final void Function()? _onChange;

  bool _running = false;
  bool _runAgain = false;

  DateTime _now() => _clock().toUtc();

  Future<SyncRunResult> process({
    required String ownerId,
    required String businessId,
  }) async {
    final current = _currentOwnerId();
    if (current == null) {
      return const SyncRunResult(skipped: true);
    }
    if (current != ownerId) {
      AppLogger.warning(
        'Refusing to sync queued operations for a different owner.',
      );
      return const SyncRunResult(skipped: true);
    }
    if (ownerId.isEmpty || businessId.isEmpty) {
      return const SyncRunResult(skipped: true);
    }
    if (_running) {
      _runAgain = true;
      return const SyncRunResult(alreadyRunning: true);
    }
    _running = true;
    var processed = 0;
    var succeeded = 0;
    var retryable = 0;
    var permanent = 0;
    try {
      await _outbox.recoverInterrupted();
      do {
        _runAgain = false;
        final due = await _outbox.listDue(
          ownerId: ownerId,
          businessId: businessId,
          now: _now(),
        );
        for (final operation in due) {
          if (_currentOwnerId() != ownerId) {
            return SyncRunResult(
              processed: processed,
              succeeded: succeeded,
              retryable: retryable,
              permanent: permanent,
              skipped: true,
            );
          }
          if (operation.dependsOnOperationId != null) {
            final dependency = await _outbox.findById(
              operation.dependsOnOperationId!,
            );
            if (dependency == null ||
                dependency.state != OutboxState.succeeded) {
              continue;
            }
          }
          final outcome = await _dispatch(operation);
          processed += 1;
          switch (outcome) {
            case _DispatchOutcome.succeeded:
              succeeded += 1;
            case _DispatchOutcome.retryable:
              retryable += 1;
            case _DispatchOutcome.permanent:
              permanent += 1;
          }
        }
      } while (_runAgain);
    } finally {
      _running = false;
    }
    _onChange?.call();
    return SyncRunResult(
      processed: processed,
      succeeded: succeeded,
      retryable: retryable,
      permanent: permanent,
    );
  }

  Future<void> retry(String operationId) async {
    await _outbox.requestManualRetry(operationId, _now());
    _onChange?.call();
  }

  Future<_DispatchOutcome> _dispatch(OutboxOperation operation) async {
    await _outbox.markSyncing(operation.operationId, _now());
    _onChange?.call();
    final attempts = operation.attemptCount + 1;
    try {
      switch (operation.operationType) {
        case OutboxOperationTypes.createTransactionV1:
          await _pushTransaction(operation);
        case OutboxOperationTypes.createObligationV1:
          await _pushObligation(operation);
        default:
          throw const AuthFailure(
            'This queued change is not supported and was not sent.',
          );
      }
      await _outbox.markSucceeded(operation.operationId, _now());
      return _DispatchOutcome.succeeded;
    } catch (error) {
      if (SyncPolicy.isRetryable(error)) {
        await _outbox.markRetryable(
          operationId: operation.operationId,
          error: error,
          now: _now(),
          attemptCount: attempts,
        );
        return _DispatchOutcome.retryable;
      }
      await _outbox.markPermanent(
        operationId: operation.operationId,
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

enum _DispatchOutcome { succeeded, retryable, permanent }
