import '../../../core/logging/app_logger.dart';
import '../../../core/persistence/obligation_cache.dart';
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
  }) : _remote = remote,
       _cache = cache,
       _currentOwnerId = currentOwnerId;

  final ObligationRepository _remote;
  final ObligationCache _cache;
  final String? Function() _currentOwnerId;

  @override
  Future<ObligationListSnapshot> listAllConfirmed({
    required String ownerId,
    required String businessId,
  }) async {
    _requireOwner(ownerId);
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
      return remote;
    } on AuthFailure catch (error) {
      if (!error.isRetryable) {
        rethrow;
      }
      final cached = await _cache.listConfirmed(
        ownerId: ownerId,
        businessId: businessId,
      );
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
    final saved = await _remote.create(
      ownerId: ownerId,
      businessId: businessId,
      currencyCode: currencyCode,
      draft: draft,
    );
    final owned = _owned(saved, ownerId, businessId);
    await _cache.upsertConfirmed(owned);
    return owned;
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
