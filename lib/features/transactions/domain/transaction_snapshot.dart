import 'business_transaction.dart';

enum TransactionDataOrigin { remote, localCache }

class TransactionListSnapshot {
  const TransactionListSnapshot({
    required this.items,
    required this.origin,
    this.refreshError,
    this.hasMore = false,
  });

  factory TransactionListSnapshot.remote(
    List<BusinessTransaction> items, {
    bool hasMore = false,
  }) {
    return TransactionListSnapshot(
      items: items,
      origin: TransactionDataOrigin.remote,
      hasMore: hasMore,
    );
  }

  factory TransactionListSnapshot.fromCache(
    List<BusinessTransaction> items, {
    bool hasMore = false,
  }) {
    return TransactionListSnapshot(
      items: items,
      origin: TransactionDataOrigin.localCache,
      hasMore: hasMore,
    );
  }

  factory TransactionListSnapshot.stale({
    required List<BusinessTransaction> items,
    required String refreshError,
    bool hasMore = false,
  }) {
    return TransactionListSnapshot(
      items: items,
      origin: TransactionDataOrigin.localCache,
      refreshError: refreshError,
      hasMore: hasMore,
    );
  }

  final List<BusinessTransaction> items;
  final TransactionDataOrigin origin;
  final String? refreshError;
  final bool hasMore;

  bool get isStale => origin == TransactionDataOrigin.localCache;
}
