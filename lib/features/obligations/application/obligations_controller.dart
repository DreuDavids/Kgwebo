import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/sync/outbox_models.dart';
import '../../../core/sync/outbox_store.dart';
import '../../../core/sync/pending_presentation.dart';
import '../../authentication/application/session_controller.dart';
import '../../authentication/domain/app_session.dart';
import '../../authentication/domain/auth_failure.dart';
import '../domain/business_obligation.dart';
import 'obligation_repository.dart';
import 'obligation_tick.dart';

class ObligationsViewState {
  const ObligationsViewState({
    this.loading = false,
    this.items = const [],
    this.isStale = false,
    this.isPreview = false,
    this.error,
    this.deleting = false,
  });

  final bool loading;
  final List<BusinessObligation> items;
  final bool isStale;
  final bool isPreview;
  final String? error;
  final bool deleting;

  ObligationsViewState copyWith({
    bool? loading,
    List<BusinessObligation>? items,
    bool? isStale,
    bool? isPreview,
    String? error,
    bool? deleting,
    bool clearError = false,
  }) {
    return ObligationsViewState(
      loading: loading ?? this.loading,
      items: items ?? this.items,
      isStale: isStale ?? this.isStale,
      isPreview: isPreview ?? this.isPreview,
      error: clearError ? null : (error ?? this.error),
      deleting: deleting ?? this.deleting,
    );
  }
}

final obligationsControllerProvider = StateNotifierProvider.autoDispose<
  ObligationsController,
  ObligationsViewState
>((ref) {
  final controller = ObligationsController(
    session: ref.watch(appSessionProvider),
    repository: ref.watch(obligationRepositoryProvider),
    outbox: ref.watch(outboxStoreProvider),
  );
  ref.listen<int>(obligationTickProvider, (_, __) {
    controller.refresh();
  });
  ref.listen<int>(syncTickProvider, (_, __) {
    controller.refresh();
  });
  return controller;
});

class ObligationsController extends StateNotifier<ObligationsViewState> {
  ObligationsController({
    required AppSession session,
    required ObligationRepository repository,
    OutboxStore? outbox,
  }) : _session = session,
       _repository = repository,
       _outbox = outbox,
       super(const ObligationsViewState(loading: true)) {
    _load();
  }

  final AppSession _session;
  final ObligationRepository _repository;
  final OutboxStore? _outbox;

  Future<void> refresh() => _load();

  Future<void> _load() async {
    final session = _session;
    if (session is AppSessionPreview) {
      state = const ObligationsViewState(isPreview: true);
      return;
    }
    if (session is! AppSessionReady) {
      state = const ObligationsViewState();
      return;
    }
    final pending =
        _outbox == null
            ? const <OutboxOperation>[]
            : await _outbox.listOpen(
              ownerId: session.user.id,
              businessId: session.business.id,
            );
    if (!mounted) {
      return;
    }
    if (pending.isNotEmpty && state.items.isEmpty) {
      state = ObligationsViewState(
        items: mergePendingObligations(
          confirmed: const [],
          operations: pending,
        ),
        loading: true,
      );
    } else {
      state = state.copyWith(loading: true, clearError: true);
    }
    try {
      final snapshot = await _repository.listAllConfirmed(
        ownerId: session.user.id,
        businessId: session.business.id,
        onLocalCache: (cached) {
          if (!mounted) {
            return;
          }
          final items = mergePendingObligations(
            confirmed: cached.items,
            operations: pending,
          );
          if (items.isEmpty) {
            return;
          }
          state = ObligationsViewState(items: items, isStale: true);
        },
      );
      if (!mounted) {
        return;
      }
      state = ObligationsViewState(
        items: mergePendingObligations(
          confirmed: snapshot.items,
          operations: pending,
        ),
        isStale: snapshot.isStale,
        error: snapshot.refreshError,
      );
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }
      if (state.items.isNotEmpty) {
        state = state.copyWith(
          loading: false,
          isStale: true,
          error: error.message,
        );
        return;
      }
      final items = mergePendingObligations(
        confirmed: const [],
        operations: pending,
      );
      if (items.isNotEmpty) {
        state = ObligationsViewState(
          items: items,
          isStale: true,
          error: error.message,
        );
        return;
      }
      state = ObligationsViewState(isStale: true, error: error.message);
    }
  }
}
