import '../../../core/finance/cash_outlook.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/persistence/obligation_cache.dart';
import '../../../core/sync/outbox_models.dart';
import '../../../core/sync/outbox_store.dart';
import '../../authentication/domain/auth_failure.dart';
import '../application/obligation_repository.dart';
import '../domain/business_obligation.dart';
import '../domain/obligation_draft.dart';
import '../domain/obligation_snapshot.dart';

class CachedObligationRepository implements ObligationRepository {
  CachedObligationRepository({
    required ObligationRepository remote,
    required ObligationCache cache,
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

  final ObligationRepository _remote;
  final ObligationCache _cache;
  final String? Function() _currentOwnerId;
  final OutboxStore? _outbox;
  final void Function()? _onOutboxChanged;
  final void Function()? _onQueued;

  @override
  Future<ObligationListSnapshot> listAllConfirmed({
    required String ownerId,
    required String businessId,
    void Function(ObligationListSnapshot cached)? onLocalCache,
  }) async {
    _requireOwner(ownerId);
    final cached = await _cache.listConfirmed(
      ownerId: ownerId,
      businessId: businessId,
    );
    if (cached.isNotEmpty) {
      onLocalCache?.call(ObligationListSnapshot.fromCache(cached));
    }
    try {
      final remote = await _remote.listAllConfirmed(
        ownerId: ownerId,
        businessId: businessId,
      );
      await _cache.replaceForBusiness(
        ownerId: ownerId,
        businessId: businessId,
        obligations: remote.items,
      );
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
      if (cached.isEmpty) {
        rethrow;
      }
      AppLogger.info(
        'Using confirmed commitment cache after a remote read failure.',
      );
      return ObligationListSnapshot.stale(
        items: cached,
        refreshError: error.message,
      );
    }
  }

  @override
  Future<BusinessObligation?> findById({
    required String ownerId,
    required String businessId,
    required String obligationId,
  }) async {
    _requireOwner(ownerId);
    try {
      final remote = await _remote.findById(
        ownerId: ownerId,
        businessId: businessId,
        obligationId: obligationId,
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
        obligationId: obligationId,
      );
      if (cached == null) {
        rethrow;
      }
      return cached;
    }
  }

  @override
  Future<BusinessObligation> create({
    required String ownerId,
    required String businessId,
    required String currencyCode,
    required ObligationDraft draft,
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
      if (draft.status != CommitmentStatus.unpaid) {
        throw const AuthFailure(
          'Marking a bill paid or cancelled needs an internet connection.',
        );
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
  Future<BusinessObligation> update({
    required String ownerId,
    required String businessId,
    required String currencyCode,
    required ObligationDraft draft,
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
          'The server returned a different commitment than the one being edited.',
        );
      }
      await _cache.upsertConfirmed(owned);
      return owned;
    } catch (error) {
      AppLogger.warning(
        'Commitment update did not reach the server; confirmed cache was kept.',
      );
      rethrow;
    }
  }

  @override
  Future<void> delete({
    required String ownerId,
    required String businessId,
    required String obligationId,
  }) async {
    _requireOwner(ownerId);
    await _remote.delete(
      ownerId: ownerId,
      businessId: businessId,
      obligationId: obligationId,
    );
    await _cache.deleteConfirmed(
      ownerId: ownerId,
      businessId: businessId,
      obligationId: obligationId,
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

  Future<BusinessObligation> _queueCreate({
    required String ownerId,
    required String businessId,
    required String currencyCode,
    required ObligationDraft draft,
  }) async {
    final payload = CreateObligationPayload.fromDraft(
      currencyCode: currencyCode,
      draft: draft,
    );
    final queued = await _outbox!.enqueue(
      ownerId: ownerId,
      businessId: businessId,
      operationType: OutboxOperationTypes.createObligationV1,
      payloadJson: payload.encode(),
      idempotencyKey: draft.idempotencyKey,
    );
    _onOutboxChanged?.call();
    _onQueued?.call();
    AppLogger.info('Queued a commitment create for later synchronisation.');
    return payload.toPendingObligation(
      operationId: queued.operationId,
      ownerId: ownerId,
      businessId: businessId,
      createdAt: queued.createdAt,
    );
  }

  Future<void> _reconcileConfirmed({
    required String ownerId,
    required String businessId,
    required List<BusinessObligation> confirmed,
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

  BusinessObligation _owned(
    BusinessObligation obligation,
    String ownerId,
    String businessId,
  ) {
    if (!obligation.belongsTo(ownerId: ownerId, businessId: businessId)) {
      throw const AuthFailure(
        'This commitment does not belong to the signed-in account.',
      );
    }
    return obligation;
  }
}
