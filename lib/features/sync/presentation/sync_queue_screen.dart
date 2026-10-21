import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/kgwebo_colors.dart';
import '../../../app/theme/kgwebo_spacing.dart';
import '../../../core/finance/ledger_entry.dart';
import '../../../core/money/money_formatter.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/sync/outbox_models.dart';
import '../../../shared/widgets/kgwebo_button.dart';
import '../../../shared/widgets/kgwebo_empty_state.dart';
import '../../../shared/widgets/kgwebo_loading_state.dart';
import '../../../shared/widgets/kgwebo_soft_card.dart';
import '../../../shared/widgets/kgwebo_status_banner.dart';
import '../../authentication/application/session_controller.dart';
import '../../authentication/domain/app_session.dart';
import '../application/sync_queue_controller.dart';
import 'sync_status_label.dart';

class SyncQueueScreen extends ConsumerWidget {
  const SyncQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider);
    final state = ref.watch(syncQueueControllerProvider);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Pending changes')),
      body: SafeArea(
        child: KgweboContentConstraint(
          child: _body(context, ref, session, state, textTheme),
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    AppSession session,
    SyncQueueState state,
    TextTheme textTheme,
  ) {
    if (session is AppSessionPreview) {
      return const KgweboEmptyState(
        icon: Icons.cloud_off_outlined,
        title: 'Preview does not queue writes',
        message:
            'Sign in to record sales and commitments. Offline writes are not mixed with preview data.',
      );
    }
    if (session is! AppSessionReady) {
      return const KgweboEmptyState(
        icon: Icons.lock_outline,
        title: 'Sign in to review queued changes',
        message:
            'Pending financial data stays on this device, keyed to the owner who created it.',
      );
    }
    if (state.loading && state.operations.isEmpty) {
      return const KgweboLoadingState(message: 'Loading pending changes');
    }
    if (state.error != null && state.operations.isEmpty) {
      return KgweboEmptyState(
        icon: Icons.cloud_off_outlined,
        title: 'Could not load the sync queue',
        message: state.error!,
        actionLabel: 'Retry',
        onAction:
            () => ref.read(syncQueueControllerProvider.notifier).refresh(),
      );
    }
    if (state.operations.isEmpty) {
      return const KgweboEmptyState(
        icon: Icons.check_circle_outline,
        title: 'Nothing waiting to sync',
        message:
            'Confirmed records are saved on the server. This list only shows changes that have not been accepted yet.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        KgweboSpacing.md,
        KgweboSpacing.md,
        KgweboSpacing.md,
        KgweboSpacing.xl,
      ),
      children: [
        const KgweboStatusBanner(
          tone: KgweboBannerTone.info,
          message:
              'Waiting items are stored on this device. They are not confirmed cash, sales or expenses until the server accepts them. Product sales and stock changes still need a live connection.',
        ),
        const SizedBox(height: KgweboSpacing.md),
        KgweboButton(
          label: state.syncing ? 'Synchronising' : 'Try synchronising now',
          icon: Icons.sync,
          expanded: true,
          isLoading: state.syncing,
          onPressed:
              state.syncing
                  ? null
                  : () =>
                      ref.read(syncQueueControllerProvider.notifier).syncNow(),
        ),
        const SizedBox(height: KgweboSpacing.lg),
        for (final operation in state.operations) ...[
          _OperationCard(
            operation: operation,
            onRetry:
                operation.state == OutboxState.succeeded
                    ? null
                    : () => ref
                        .read(syncQueueControllerProvider.notifier)
                        .retry(operation.operationId),
          ),
          const SizedBox(height: KgweboSpacing.sm),
        ],
        Text(
          'Queued changes belong to the signed-in owner and this business. Signing out hides them from other accounts without submitting them.',
          style: textTheme.bodySmall?.copyWith(color: KgweboColors.inkMuted),
        ),
      ],
    );
  }
}

class _OperationCard extends StatelessWidget {
  const _OperationCard({required this.operation, this.onRetry});

  final OutboxOperation operation;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return KgweboSoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KgweboSyncStatusLabel(state: operation.state),
          const SizedBox(height: KgweboSpacing.sm),
          Text(_title(operation), style: textTheme.titleSmall),
          const SizedBox(height: KgweboSpacing.xxs),
          Text(
            _detail(operation),
            style: textTheme.bodyMedium?.copyWith(color: KgweboColors.inkMuted),
          ),
          if (operation.lastErrorMessage != null) ...[
            const SizedBox(height: KgweboSpacing.sm),
            Text(operation.lastErrorMessage!, style: textTheme.bodyMedium),
          ],
          if (onRetry != null &&
              (operation.state == OutboxState.retryableFailure ||
                  operation.state == OutboxState.permanentFailure ||
                  operation.state == OutboxState.pending)) ...[
            const SizedBox(height: KgweboSpacing.sm),
            KgweboButton(
              label:
                  operation.state.needsUserAction
                      ? 'Retry this change'
                      : 'Retry now',
              variant: KgweboButtonVariant.secondary,
              expanded: true,
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    );
  }

  String _title(OutboxOperation operation) {
    return switch (operation.operationType) {
      OutboxOperationTypes.createTransactionV1 => _transactionTitle(operation),
      OutboxOperationTypes.createObligationV1 => _obligationTitle(operation),
      _ => 'Queued change',
    };
  }

  String _transactionTitle(OutboxOperation operation) {
    final payload = operation.asCreateTransaction();
    final amount = MoneyFormatter.formatMinor(
      payload.amountMinor,
      currencyCode: payload.currencyCode,
    );
    final kind = switch (payload.type) {
      MoneyMovementType.sale => 'Sale',
      MoneyMovementType.expense => 'Expense',
      MoneyMovementType.refund => 'Refund',
      MoneyMovementType.ownerContribution => 'Owner contribution',
      MoneyMovementType.ownerWithdrawal => 'Owner withdrawal',
    };
    return '$kind · $amount';
  }

  String _obligationTitle(OutboxOperation operation) {
    final payload = operation.asCreateObligation();
    return 'Commitment · ${payload.title}';
  }

  String _detail(OutboxOperation operation) {
    if (operation.operationType == OutboxOperationTypes.createTransactionV1) {
      final payload = operation.asCreateTransaction();
      return payload.category;
    }
    if (operation.operationType == OutboxOperationTypes.createObligationV1) {
      return operation.asCreateObligation().category;
    }
    return operation.operationType;
  }
}
