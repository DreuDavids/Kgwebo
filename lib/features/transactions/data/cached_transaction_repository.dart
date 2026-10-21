import '../../../core/finance/business_calendar.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/persistence/transaction_cache.dart';
import '../../../core/sync/outbox_models.dart';
import '../../../core/sync/outbox_store.dart';
import '../../authentication/domain/auth_failure.dart';
import '../application/transaction_repository.dart';
import '../domain/business_transaction.dart';
import '../domain/transaction_draft.dart';
import '../domain/transaction_query.dart';
import '../domain/transaction_snapshot.dart';

class CachedTransactionRepository implements TransactionRepository {
  CachedTransactionRepository({
    required TransactionRepository remote,
    required TransactionCache cache,
    required String? Function() currentOwnerId,
    OutboxStore? outbox,
    void Function()? onOutboxChanged,
    void Function()? onQueued,
  }) : _remote = remote,
       _cache = cache,
       _currentOwnerId = currentOwnerId,
       _outbox = outbox,
       _onOutboxChanged = onOutboxChanged,
       _onQueued = onQueued;

  final TransactionRepository _remote;
  final TransactionCache _cache;
  final String? Function() _currentOwnerId;
  final OutboxStore? _outbox;
  final void Function()? _onOutboxChanged;
  final void Function()? _onQueued;

  @override
  Future<TransactionListSnapshot> list({
    required String ownerId,
    required String businessId,
    TransactionQuery query = const TransactionQuery(),
  }) async {
    _requireOwner(ownerId);
    try {
      final remote = await _remote.list(
        ownerId: ownerId,
        businessId: businessId,
        query: query,
      );
      await _cache.upsertAll(remote.items);
      await _reconcileConfirmed(
        ownerId: ownerId,
        businessId: businessId,
        confirmed: remote.items,
      );
      return remote;
    } on AuthFailure catch (error) {
      if (!error.isRetryable) {
        rethrow;
      }
      final cached = await _cache.listConfirmed(
        ownerId: ownerId,
        businessId: businessId,
        query: query,
      );
      if (cached.isEmpty) {
        rethrow;
      }
      AppLogger.info(
        'Using confirmed transaction cache after a remote read failure.',
      );
      final hasMore = cached.length > query.limit;
      return TransactionListSnapshot.stale(
        items: hasMore ? cached.sublist(0, query.limit) : cached,
        refreshError: error.message,
        hasMore: hasMore,
      );
    }
  }

  @override
  Future<List<BusinessTransaction>> listConfirmedInRange({
    required String ownerId,
    required String businessId,
    required ReportingPeriod period,
  }) async {
    _requireOwner(ownerId);
    try {
      final remote = await _remote.listConfirmedInRange(
        ownerId: ownerId,
        businessId: businessId,
        period: period,
      );
      await _cache.upsertAll(remote);
      return remote;
    } on AuthFailure catch (error) {
      if (!error.isRetryable) {
        rethrow;
      }
      final cached = await _cache.listConfirmed(
        ownerId: ownerId,
        businessId: businessId,
        query: TransactionQuery(period: period, limit: 5000),
      );
      if (cached.isEmpty) {
        rethrow;
      }
      AppLogger.info(
        'Using confirmed transaction cache for period totals after a remote read failure.',
      );
      return cached;
    }
  }

  @override
  Future<TransactionListSnapshot> listAllConfirmed({
    required String ownerId,
    required String businessId,
  }) async {
    _requireOwner(ownerId);
    try {
      final remote = await _remote.listAllConfirmed(
        ownerId: ownerId,
        businessId: businessId,
      );
      if (remote.items.length < 5000) {
        await _cache.replaceForBusiness(
          ownerId: ownerId,
          businessId: businessId,
          transactions: remote.items,
        );
      } else {
        await _cache.upsertAll(remote.items);
      }
      await _reconcileConfirmed(
        ownerId: ownerId,
        businessId: businessId,
        confirmed: remote.items,
      );
      return remote;
    } on AuthFailure catch (error) {
      if (!error.isRetryable) {
        rethrow;
      }
      final cached = await _cache.listConfirmed(
        ownerId: ownerId,
        businessId: businessId,
        query: const TransactionQuery(limit: 5000),
      );
      if (cached.isEmpty) {
        rethrow;
      }
      AppLogger.info(
        'Using confirmed transaction cache after a remote read failure.',
      );
      return TransactionListSnapshot.stale(
        items: cached,
        refreshError: error.message,
      );
    }
  }

  @override
  Future<BusinessTransaction?> findById({
    required String ownerId,
    required String businessId,
    required String transactionId,
  }) async {
    _requireOwner(ownerId);
    try {
      final remote = await _remote.findById(
        ownerId: ownerId,
        businessId: businessId,
        transactionId: transactionId,
      );
      if (remote != null) {
        await _cache.upsertConfirmed(remote);
      }
      return remote;
    } on AuthFailure catch (error) {
      if (!error.isRetryable) {
        rethrow;
      }
      final cached = await _cache.findConfirmed(
        ownerId: ownerId,
        businessId: businessId,
        transactionId: transactionId,
      );
      if (cached == null) {
        rethrow;
      }
      return cached;
    }
  }

  @override
  Future<BusinessTransaction> create({
    required String ownerId,
    required String businessId,
    required String currencyCode,
    required TransactionDraft draft,
  }) async {
    _requireOwner(ownerId);
    try {
      final saved = await _remote.create(
        ownerId: ownerId,
        businessId: businessId,
        currencyCode: currencyCode,
        draft: draft,
      );
      final owned = _owned(saved, ownerId, businessId);
      await _cache.upsertConfirmed(owned);
      return owned;
    } on AuthFailure catch (error) {
      if (_outbox == null || !error.isRetryable) {
        rethrow;
      }
      return _queueCreate(
        ownerId: ownerId,
        businessId: businessId,
        currencyCode: currencyCode,
        draft: draft,
      );
    }
  }

  @override
  Future<BusinessTransaction> update({
    required String ownerId,
    required String businessId,
    required String currencyCode,
    required TransactionDraft draft,
  }) async {
    _requireOwner(ownerId);
    try {
      final saved = await _remote.update(
        ownerId: ownerId,
        businessId: businessId,
        currencyCode: currencyCode,
        draft: draft,
      );
      final owned = _owned(saved, ownerId, businessId);
      if (draft.existingId != null && owned.id != draft.existingId) {
        throw const AuthFailure(
          'The server returned a different transaction than the one being edited.',
        );
      }
      await _cache.upsertConfirmed(owned);
      return owned;
    } catch (error) {
      AppLogger.warning(
        'Transaction update did not reach the server; confirmed cache was kept.',
      );
      rethrow;
    }
  }

  @override
  Future<void> delete({
    required String ownerId,
    required String businessId,
    required String transactionId,
  }) async {
    _requireOwner(ownerId);
    await _remote.delete(
      ownerId: ownerId,
      businessId: businessId,
      transactionId: transactionId,
    );
    await _cache.deleteConfirmed(
      ownerId: ownerId,
      businessId: businessId,
      transactionId: transactionId,
    );
  }

  void _requireOwner(String ownerId) {
    final current = _currentOwnerId();
    if (current == null) {
      throw AuthFailure.fromCode('session_expired');
    }
    if (current != ownerId) {
      throw const AuthFailure(
        'This business does not belong to the signed-in account.',
      );
    }
  }

  Future<BusinessTransaction> _queueCreate({
    required String ownerId,
    required String businessId,
    required String currencyCode,
    required TransactionDraft draft,
  }) async {
    final payload = CreateTransactionPayload.fromDraft(
      currencyCode: currencyCode,
      draft: draft,
    );
    final queued = await _outbox!.enqueue(
      ownerId: ownerId,
      businessId: businessId,
      operationType: OutboxOperationTypes.createTransactionV1,
      payloadJson: payload.encode(),
      idempotencyKey: draft.idempotencyKey,
    );
    _onOutboxChanged?.call();
    _onQueued?.call();
    AppLogger.info('Queued a transaction create for later synchronisation.');
    return payload.toPendingTransaction(
      operationId: queued.operationId,
      ownerId: ownerId,
      businessId: businessId,
      createdAt: queued.createdAt,
    );
  }

  Future<void> _reconcileConfirmed({
    required String ownerId,
    required String businessId,
    required List<BusinessTransaction> confirmed,
  }) async {
    final outbox = _outbox;
    if (outbox == null || confirmed.isEmpty) {
      return;
    }
    final updated = await outbox.markSucceededMatching(
      ownerId: ownerId,
      businessId: businessId,
      idempotencyKeys: confirmed.map((item) => item.idempotencyKey),
      now: DateTime.now().toUtc(),
    );
    if (updated > 0) {
      _onOutboxChanged?.call();
    }
  }

  BusinessTransaction _owned(
    BusinessTransaction transaction,
    String ownerId,
    String businessId,
  ) {
    if (!transaction.belongsTo(ownerId: ownerId, businessId: businessId)) {
      throw const AuthFailure(
        'This transaction does not belong to the signed-in account.',
      );
    }
    return transaction;
  }
}
