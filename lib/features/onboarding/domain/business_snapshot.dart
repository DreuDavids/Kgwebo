import 'business_profile.dart';

enum BusinessDataOrigin { remote, localCache }

/// A business plus whether the value is server-confirmed or a stale cache.
class BusinessSnapshot {
  const BusinessSnapshot({
    required this.profile,
    required this.origin,
    this.refreshError,
  });

  factory BusinessSnapshot.remote(BusinessProfile profile) {
    return BusinessSnapshot(
      profile: profile,
      origin: BusinessDataOrigin.remote,
    );
  }

  factory BusinessSnapshot.stale({
    required BusinessProfile profile,
    required String refreshError,
  }) {
    return BusinessSnapshot(
      profile: profile,
      origin: BusinessDataOrigin.localCache,
      refreshError: refreshError,
    );
  }

  final BusinessProfile profile;
  final BusinessDataOrigin origin;
  final String? refreshError;

  bool get isStale => origin == BusinessDataOrigin.localCache;

  bool get isConfirmedRemote => origin == BusinessDataOrigin.remote;
}
