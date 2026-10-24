import 'business_obligation.dart';

enum ObligationDataOrigin { remote, localCache }

class ObligationListSnapshot {
  const ObligationListSnapshot({
    required this.items,
    required this.origin,
    this.refreshError,
  });

  factory ObligationListSnapshot.remote(List<BusinessObligation> items) {
    return ObligationListSnapshot(
      items: items,
      origin: ObligationDataOrigin.remote,
    );
  }

  factory ObligationListSnapshot.fromCache(List<BusinessObligation> items) {
    return ObligationListSnapshot(
      items: items,
      origin: ObligationDataOrigin.localCache,
    );
  }

  factory ObligationListSnapshot.stale({
    required List<BusinessObligation> items,
    required String refreshError,
  }) {
    return ObligationListSnapshot(
      items: items,
      origin: ObligationDataOrigin.localCache,
      refreshError: refreshError,
    );
  }

  final List<BusinessObligation> items;
  final ObligationDataOrigin origin;
  final String? refreshError;

  bool get isStale => origin == ObligationDataOrigin.localCache;
}
