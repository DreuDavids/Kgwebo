import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/finance/business_calendar.dart';
import '../../../core/finance/dashboard_period.dart';
import '../../../core/finance/ledger_entry.dart';
import '../../../core/sync/outbox_models.dart';
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
    this.type,
    this.periodKind,
    this.periodLabel = 'All time',
    this.category,
  });

  final bool loading;
  final bool loadingMore;
  final bool deleting;
  final TransactionListSnapshot? snapshot;
  final String? error;
  final String search;
  final MoneyMovementType? type;
  final DashboardPeriodKind? periodKind;
  final String periodLabel;
  final String? category;

  List<BusinessTransaction> get items => snapshot?.items ?? const [];

  bool get isStale => snapshot?.isStale ?? false;

  bool get hasMore => snapshot?.hasMore ?? false;

  bool get hasActiveFilters =>
      type != null || periodKind != null || category != null;

  TransactionsViewState copyWith({
    bool? loading,
    bool? loadingMore,
    bool? deleting,
    TransactionListSnapshot? snapshot,
    String? error,
    String? search,
    MoneyMovementType? type,
    DashboardPeriodKind? periodKind,
    String? periodLabel,
    String? category,
    bool clearError = false,
    bool clearSnapshot = false,
    bool clearType = false,
    bool clearPeriod = false,
    bool clearCategory = false,
  }) {
    return TransactionsViewState(
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      deleting: deleting ?? this.deleting,
      snapshot: clearSnapshot ? null : (snapshot ?? this.snapshot),
      error: clearError ? null : (error ?? this.error),
      search: search ?? this.search,
      type: clearType ? null : (type ?? this.type),
      periodKind: clearPeriod ? null : (periodKind ?? this.periodKind),
      periodLabel: periodLabel ?? this.periodLabel,
      category: clearCategory ? null : (category ?? this.category),
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
  DateTime? _customStart;
  DateTime? _customEnd;

  TransactionQuery _query({DateTime? beforeOccurredAt, String? beforeId}) {
    return TransactionQuery(
      search: state.search,
      type: state.type,
      period: _selectedPeriod(),
      category: state.category,
      beforeOccurredAt: beforeOccurredAt,
      beforeId: beforeId,
    );
  }

  ReportingPeriod? _selectedPeriod() {
    final kind = state.periodKind;
    if (kind == null) {
      return null;
    }
    final session = _session;
    final zone =
        session is AppSessionReady
            ? BusinessZone.forCountry(session.business.countryCode)
            : BusinessZone.africaGaborone;
    return DashboardPeriodSelection.resolve(
      kind: kind,
      nowUtc: DateTime.now().toUtc(),
      zone: zone,
      customStartWall: _customStart,
      customEndWall: _customEnd,
    ).period;
  }

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
        query: _query(),
      );
      if (!mounted) {
        return;
      }
      final items = await _withPending(
        ownerId: ready.user.id,
        businessId: ready.business.id,
        confirmed: snapshot.items,
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
    state = state.copyWith(search: search, clearSnapshot: true);
    await _load();
  }

  Future<void> applyTypeFilter(MoneyMovementType? type) async {
    state = state.copyWith(
      type: type,
      clearType: type == null,
      clearCategory: true,
      clearSnapshot: true,
    );
    await _load();
  }

  Future<void> applyCategoryFilter(String? category) async {
    state = state.copyWith(
      category: category,
      clearCategory: category == null || category.isEmpty,
      clearSnapshot: true,
    );
    await _load();
  }

  Future<void> applyPeriodFilter(
    DashboardPeriodKind? kind, {
    DateTime? customStart,
    DateTime? customEnd,
  }) async {
    _customStart = customStart;
    _customEnd = customEnd;
    if (kind == null) {
      state = state.copyWith(
        clearPeriod: true,
        periodLabel: 'All time',
        clearSnapshot: true,
      );
    } else {
      final session = _session;
      final zone =
          session is AppSessionReady
              ? BusinessZone.forCountry(session.business.countryCode)
              : BusinessZone.africaGaborone;
      final selection = DashboardPeriodSelection.resolve(
        kind: kind,
        nowUtc: DateTime.now().toUtc(),
        zone: zone,
        customStartWall: customStart,
        customEndWall: customEnd,
      );
      state = state.copyWith(
        periodKind: selection.kind,
        periodLabel: selection.label,
        clearSnapshot: true,
      );
    }
    await _load();
  }

  Future<void> clearFilters() async {
    _customStart = null;
    _customEnd = null;
    state = state.copyWith(
      clearType: true,
      clearPeriod: true,
      periodLabel: 'All time',
      clearCategory: true,
      clearSnapshot: true,
    );
    await _load();
  }

  Future<void> loadMore() async {
    final ready = _session;
    final snapshot = state.snapshot;
    if (ready is! AppSessionReady ||
        snapshot == null ||
        !snapshot.hasMore ||
        state.loading ||
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
        query: _query(
          beforeOccurredAt: lastConfirmed.occurredAt,
          beforeId: lastConfirmed.id,
        ),
      );
      if (!mounted) {
        return;
      }
      final outbox = _outbox;
      final operations =
          outbox == null
              ? const <OutboxOperation>[]
              : await outbox.listOpen(
                ownerId: ready.user.id,
                businessId: ready.business.id,
              );
      if (!mounted) {
        return;
      }
      final merged =
          mergeHistoryPages(
            existing: snapshot.items,
            page: page.items,
            operations: operations,
          ).where(_matchesFilters).toList();
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
  }) async {
    final outbox = _outbox;
    var merged = confirmed;
    if (outbox != null) {
      final pending = await outbox.listOpen(
        ownerId: ownerId,
        businessId: businessId,
      );
      merged = mergePendingTransactions(
        confirmed: confirmed,
        operations: pending,
      );
    }
    merged = merged.where(_matchesFilters).toList();
    return _uniqueById(merged);
  }

  bool _matchesFilters(BusinessTransaction item) {
    if (state.type != null && item.type != state.type) {
      return false;
    }
    if (state.category != null && item.category != state.category) {
      return false;
    }
    final period = _selectedPeriod();
    if (period != null && !period.contains(item.occurredAt)) {
      return false;
    }
    final needle = state.search.trim().toLowerCase();
    if (needle.isEmpty) {
      return true;
    }
    final description = item.description?.toLowerCase() ?? '';
    return item.category.toLowerCase().contains(needle) ||
        description.contains(needle);
  }

  List<BusinessTransaction> _uniqueById(List<BusinessTransaction> items) {
    final seen = <String>{};
    return [
      for (final item in items)
        if (seen.add(item.id)) item,
    ];
  }
}
