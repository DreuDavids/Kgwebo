import '../../../core/logging/app_logger.dart';
import '../../../core/persistence/business_cache.dart';
import '../../authentication/domain/auth_failure.dart';
import '../application/onboarding_repository.dart';
import '../domain/business_profile.dart';
import '../domain/business_snapshot.dart';
import '../domain/onboarding_draft.dart';

class CachedOnboardingRepository implements OnboardingRepository {
  CachedOnboardingRepository({
    required OnboardingRepository remote,
    required BusinessCache cache,
    required String? Function() currentOwnerId,
  }) : _remote = remote,
       _cache = cache,
       _currentOwnerId = currentOwnerId;

  final OnboardingRepository _remote;
  final BusinessCache _cache;
  final String? Function() _currentOwnerId;

  @override
  Future<BusinessProfile?> findOwnedBusiness() async {
    return (await loadOwnedBusiness())?.profile;
  }

  @override
  Future<BusinessSnapshot?> loadOwnedBusiness() async {
    final ownerId = _currentOwnerId();
    if (ownerId == null) {
      return null;
    }
    try {
      final remote = await _remote.findOwnedBusiness();
      if (remote == null) {
        await _cache.deleteForOwner(ownerId);
        return null;
      }
      final owned = _requireOwned(remote, ownerId);
      await _cache.upsertConfirmed(owned);
      return BusinessSnapshot.remote(owned);
    } on AuthFailure catch (error) {
      if (!error.isRetryable) {
        rethrow;
      }
      final cached = await _confirmedCache(ownerId);
      if (cached == null) {
        rethrow;
      }
      AppLogger.info(
        'Using confirmed business cache after a remote read failure.',
      );
      return BusinessSnapshot.stale(
        profile: cached,
        refreshError: error.message,
      );
    }
  }

  @override
  Future<BusinessProfile> save(OnboardingDraft draft) async {
    final ownerId = _requireOwnerId();
    final saved = _requireOwned(await _remote.save(draft), ownerId);
    await _cache.upsertConfirmed(saved);
    return saved;
  }

  @override
  Future<BusinessProfile> updateExisting({
    required String businessId,
    required OnboardingDraft draft,
  }) async {
    final ownerId = _requireOwnerId();
    final cached = await _confirmedCache(ownerId);
    if (cached != null && cached.id != businessId) {
      throw const AuthFailure(
        'Could not update this business. It may not exist or you may not own it.',
      );
    }
    try {
      final updated = _requireOwned(
        await _remote.updateExisting(businessId: businessId, draft: draft),
        ownerId,
      );
      if (updated.id != businessId) {
        throw const AuthFailure(
          'The server returned a different business than the one being edited.',
        );
      }
      await _cache.upsertConfirmed(updated);
      return updated;
    } catch (error) {
      AppLogger.warning(
        'Business update did not reach the server; confirmed cache was kept.',
      );
      rethrow;
    }
  }

  Future<BusinessProfile?> _confirmedCache(String ownerId) async {
    final cached = await _cache.findConfirmedForOwner(ownerId);
    if (cached == null) {
      return null;
    }
    return _requireOwned(cached, ownerId);
  }

  BusinessProfile _requireOwned(BusinessProfile profile, String ownerId) {
    if (!profile.belongsTo(ownerId)) {
      throw const AuthFailure(
        'This business does not belong to the signed-in account.',
      );
    }
    return profile;
  }

  String _requireOwnerId() {
    final ownerId = _currentOwnerId();
    if (ownerId == null) {
      throw AuthFailure.fromCode('session_expired');
    }
    return ownerId;
  }
}
