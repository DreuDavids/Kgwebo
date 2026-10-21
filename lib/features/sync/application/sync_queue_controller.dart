import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/sync/outbox_models.dart';
import '../../../core/sync/outbox_store.dart';
import '../../../core/sync/sync_coordinator.dart';
import '../../authentication/application/session_controller.dart';
import '../../authentication/domain/app_session.dart';
import '../../obligations/application/obligation_tick.dart';
import '../../transactions/application/transaction_tick.dart';

class SyncQueueState {
  const SyncQueueState({
    this.loading = false,
    this.syncing = false,
    this.operations = const [],
    this.error,
  });

  final bool loading;
  final bool syncing;
  final List<OutboxOperation> operations;
  final String? error;

  int get waitingCount =>
      operations
          .where(
            (item) =>
                item.state == OutboxState.pending ||
                item.state == OutboxState.retryableFailure ||
                item.state == OutboxState.syncing,
          )
          .length;

  int get actionRequiredCount =>
      operations.where((item) => item.state.needsUserAction).length;

  bool get hasOpen => operations.isNotEmpty;

  SyncQueueState copyWith({
    bool? loading,
    bool? syncing,
    List<OutboxOperation>? operations,
    String? error,
    bool clearError = false,
  }) {
    return SyncQueueState(
      loading: loading ?? this.loading,
      syncing: syncing ?? this.syncing,
      operations: operations ?? this.operations,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final syncQueueControllerProvider =
    StateNotifierProvider.autoDispose<SyncQueueController, SyncQueueState>((
      ref,
    ) {
      ref.watch(syncTickProvider);
      return SyncQueueController(
        session: ref.watch(appSessionProvider),
        outbox: ref.watch(outboxStoreProvider),
        coordinator: ref.watch(syncCoordinatorProvider),
        onSynced: () {
          ref.read(transactionTickProvider.notifier).state++;
          ref.read(obligationTickProvider.notifier).state++;
        },
      );
    });

class SyncQueueController extends StateNotifier<SyncQueueState> {
  SyncQueueController({
    required AppSession session,
    required OutboxStore outbox,
    required SyncCoordinator? coordinator,
    required void Function() onSynced,
  }) : _session = session,
       _outbox = outbox,
       _coordinator = coordinator,
       _onSynced = onSynced,
       super(const SyncQueueState(loading: true)) {
    _load();
  }

  final AppSession _session;
  final OutboxStore _outbox;
  final SyncCoordinator? _coordinator;
  final void Function() _onSynced;

  Future<void> refresh() => _load();

  Future<void> _load() async {
    final session = _session;
    if (session is! AppSessionReady) {
      state = const SyncQueueState();
      return;
    }
    state = state.copyWith(loading: true, clearError: true);
    try {
      final operations = await _outbox.listOpen(
        ownerId: session.user.id,
        businessId: session.business.id,
      );
      if (!mounted) {
        return;
      }
      state = SyncQueueState(operations: operations);
    } catch (error) {
      if (!mounted) {
        return;
      }
      state = SyncQueueState(error: SyncPolicy.safeMessage(error));
    }
  }

  Future<void> syncNow() async {
    final session = _session;
    final coordinator = _coordinator;
    if (session is! AppSessionReady || coordinator == null) {
      return;
    }
    state = state.copyWith(syncing: true, clearError: true);
    try {
      await coordinator.process(
        ownerId: session.user.id,
        businessId: session.business.id,
      );
      _onSynced();
      await _load();
    } finally {
      if (mounted) {
        state = state.copyWith(syncing: false);
      }
    }
  }

  Future<void> retry(String operationId) async {
    final coordinator = _coordinator;
    if (coordinator == null) {
      return;
    }
    await coordinator.retry(operationId);
    await syncNow();
  }
}
