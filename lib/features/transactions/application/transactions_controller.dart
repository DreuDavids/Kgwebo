import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/sync/outbox_store.dart';
import '../../../core/sync/pending_presentation.dart';
import '../../authentication/application/session_controller.dart';
import '../../authentication/domain/app_session.dart';
import '../../authentication/domain/auth_failure.dart';
import '../domain/business_transaction.dart';
import '../domain/transaction_query.dart';
import '../domain/transaction_snapshot.dart';
import 'transaction_repository.dart';
import 'transaction_tick.dart';

class TransactionsViewState {
  const TransactionsViewState({
    this.loading = false,
    this.loadingMore = false,
    this.deleting = false,
    this.snapshot,
    this.error,
    this.search = '',
  });

  final bool loading;
  final bool loadingMore;
  final bool deleting;
  final TransactionListSnapshot? snapshot;
  final String? error;
  final String search;

  List<BusinessTransaction> get items => snapshot?.items ?? const [];

  bool get isStale => snapshot?.isStale ?? false;

  bool get hasMore => snapshot?.hasMore ?? false;

  TransactionsViewState copyWith({
    bool? loading,
    bool? loadingMore,
    bool? deleting,
    TransactionListSnapshot? snapshot,
    String? error,
    String? search,
    bool clearError = false,
    bool clearSnapshot = false,
  }) {
    return TransactionsViewState(
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      deleting: deleting ?? this.deleting,
      snapshot: clearSnapshot ? null : (snapshot ?? this.snapshot),
      error: clearError ? null : (error ?? this.error),
      search: search ?? this.search,
    );
  }
}

final transactionsControllerProvider = StateNotifierProvider.autoDispose<
  TransactionsController,
  TransactionsViewState
>((ref) {
  ref.watch(transactionTickProvider);
  ref.watch(syncTickProvider);
  final session = ref.watch(appSessionProvider);
  return TransactionsController(
    session: session,
    repository: ref.watch(transactionRepositoryProvider),
    outbox: ref.watch(outboxStoreProvider),
  );
});

class TransactionsController extends StateNotifier<TransactionsViewState> {
  TransactionsController({
    required AppSession session,
    required TransactionRepository repository,
    OutboxStore? outbox,
  }) : _session = session,
       _repository = repository,
       _outbox = outbox,
       super(const TransactionsViewState(loading: true)) {
    _load();
  }

  final AppSession _session;
  final TransactionRepository _repository;
  final OutboxStore? _outbox;

  Future<void> _load() async {
    final ready = _session;
    if (ready is! AppSessionReady) {
      state = const TransactionsViewState();
      return;
    }
    state = state.copyWith(loading: true, clearError: true);
    try {
      final snapshot = await _repository.list(
        ownerId: ready.user.id,
        businessId: ready.business.id,
        query: TransactionQuery(search: state.search),
      );
      if (!mounted) {
        return;
      }
      final items = await _withPending(
        ownerId: ready.user.id,
        businessId: ready.business.id,
        confirmed: snapshot.items,
        search: state.search,
      );
      state = state.copyWith(
        loading: false,
        snapshot: TransactionListSnapshot(
          items: items,
          origin: snapshot.origin,
          refreshError: snapshot.refreshError,
          hasMore: snapshot.hasMore,
        ),
        error: snapshot.refreshError,
      );
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }
      if (error.isRetryable) {
        final items = await _withPending(
          ownerId: ready.user.id,
          businessId: ready.business.id,
          confirmed: const [],
          search: state.search,
        );
        if (items.isNotEmpty) {
          state = state.copyWith(
            loading: false,
            snapshot: TransactionListSnapshot.stale(
              items: items,
              refreshError: error.message,
            ),
            error: error.message,
          );
          return;
        }
      }
      state = state.copyWith(loading: false, error: error.message);
    }
  }

  Future<void> refresh() => _load();

  Future<void> applySearch(String search) async {
    state = state.copyWith(search: search);
    await _load();
  }

  Future<void> loadMore() async {
    final ready = _session;
    final snapshot = state.snapshot;
    if (ready is! AppSessionReady ||
        snapshot == null ||
        !snapshot.hasMore ||
        state.loadingMore ||
        snapshot.items.isEmpty) {
      return;
    }
    state = state.copyWith(loadingMore: true, clearError: true);
    try {
      final lastConfirmed = snapshot.items.lastWhere(
        (item) => !item.pendingSync,
        orElse: () => snapshot.items.last,
      );
      if (lastConfirmed.pendingSync) {
        state = state.copyWith(loadingMore: false);
        return;
      }
      final page = await _repository.list(
        ownerId: ready.user.id,
        businessId: ready.business.id,
        query: TransactionQuery(
          search: state.search,
          limit: 50,
          beforeOccurredAt: lastConfirmed.occurredAt,
          beforeId: lastConfirmed.id,
        ),
      );
      if (!mounted) {
        return;
      }
      final merged = _uniqueById([...snapshot.items, ...page.items]);
      state = state.copyWith(
        loadingMore: false,
        snapshot: TransactionListSnapshot(
          items: merged,
          origin: page.origin,
          refreshError: page.refreshError,
          hasMore: page.hasMore,
        ),
        error: page.refreshError,
      );
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }
      state = state.copyWith(loadingMore: false, error: error.message);
    }
  }

  Future<bool> delete(BusinessTransaction transaction) async {
    final ready = _session;
    if (ready is! AppSessionReady) {
      return false;
    }
    state = state.copyWith(deleting: true, clearError: true);
    try {
      await _repository.delete(
        ownerId: ready.user.id,
        businessId: ready.business.id,
        transactionId: transaction.id,
      );
      if (!mounted) {
        return true;
      }
      final remaining =
          state.items.where((item) => item.id != transaction.id).toList();
      state = state.copyWith(
        deleting: false,
        snapshot: TransactionListSnapshot(
          items: remaining,
          origin: TransactionDataOrigin.remote,
        ),
      );
      return true;
    } on AuthFailure catch (error) {
      if (!mounted) {
        return false;
      }
      state = state.copyWith(deleting: false, error: error.message);
      return false;
    }
  }

  Future<List<BusinessTransaction>> _withPending({
    required String ownerId,
    required String businessId,
    required List<BusinessTransaction> confirmed,
    required String search,
  }) async {
    final outbox = _outbox;
    if (outbox == null) {
      return confirmed;
    }
    final pending = await outbox.listOpen(
      ownerId: ownerId,
      businessId: businessId,
    );
    var merged = mergePendingTransactions(
      confirmed: confirmed,
      operations: pending,
    );
    final needle = search.trim().toLowerCase();
    if (needle.isNotEmpty) {
      merged =
          merged.where((item) {
            final description = item.description?.toLowerCase() ?? '';
            return item.category.toLowerCase().contains(needle) ||
                description.contains(needle);
          }).toList();
    }
    return _uniqueById(merged);
  }

  List<BusinessTransaction> _uniqueById(List<BusinessTransaction> items) {
    final seen = <String>{};
    return [
      for (final item in items)
        if (seen.add(item.id)) item,
    ];
  }
}
