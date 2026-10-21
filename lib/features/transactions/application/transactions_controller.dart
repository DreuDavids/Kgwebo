import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final session = ref.watch(appSessionProvider);
  return TransactionsController(
    session: session,
    repository: ref.watch(transactionRepositoryProvider),
  );
});

class TransactionsController extends StateNotifier<TransactionsViewState> {
  TransactionsController({
    required AppSession session,
    required TransactionRepository repository,
  }) : _session = session,
       _repository = repository,
       super(const TransactionsViewState(loading: true)) {
    _load();
  }

  final AppSession _session;
  final TransactionRepository _repository;

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
      state = state.copyWith(
        loading: false,
        snapshot: snapshot,
        error: snapshot.refreshError,
      );
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
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
      final last = snapshot.items.last;
      final page = await _repository.list(
        ownerId: ready.user.id,
        businessId: ready.business.id,
        query: TransactionQuery(
          search: state.search,
          limit: 50,
          beforeOccurredAt: last.occurredAt,
          beforeId: last.id,
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

  List<BusinessTransaction> _uniqueById(List<BusinessTransaction> items) {
    final seen = <String>{};
    return [
      for (final item in items)
        if (seen.add(item.id)) item,
    ];
  }
}
