import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme/kgwebo_colors.dart';
import '../../../app/theme/kgwebo_radii.dart';
import '../../../app/theme/kgwebo_spacing.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../shared/widgets/kgwebo_button.dart';
import '../../../shared/widgets/kgwebo_empty_state.dart';
import '../../../shared/widgets/kgwebo_loading_state.dart';
import '../../../shared/widgets/kgwebo_status_banner.dart';
import '../../../shared/widgets/kgwebo_text_field.dart';
import '../../../core/sync/outbox_models.dart';
import '../../authentication/application/session_controller.dart';
import '../../authentication/domain/app_session.dart';
import '../../sync/application/sync_queue_controller.dart';
import '../../sync/presentation/sync_notice.dart';
import '../application/transactions_controller.dart';
import '../domain/business_transaction.dart';
import 'widgets/transaction_filters.dart';
import 'widgets/transaction_list_item.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  late final TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () {
      ref.read(transactionsControllerProvider.notifier).applySearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(appSessionProvider);
    final state = ref.watch(transactionsControllerProvider);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      appBar: AppBar(title: const Text('Money')),
      body: SafeArea(
        child: KgweboFilledBody(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  KgweboSpacing.md,
                  KgweboSpacing.sm,
                  KgweboSpacing.md,
                  0,
                ),
                child: KgweboTextField(
                  controller: _searchController,
                  label: 'Search sales or expenses',
                  hint: 'Category or note',
                  prefixIcon: Icons.search,
                  textInputAction: TextInputAction.search,
                  onChanged: _onSearch,
                ),
              ),
              const TransactionFilters(),
              const SizedBox(height: KgweboSpacing.sm),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: KgweboSpacing.md),
                child: _RecordMoneyActions(),
              ),
              const SizedBox(height: KgweboSpacing.sm),
              Expanded(child: _buildList(session, state, bottomInset)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(
    AppSession session,
    TransactionsViewState state,
    double bottomInset,
  ) {
    if (session is AppSessionPreview) {
      return const KgweboEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No live money history',
        message: 'Sign in to record sales and expenses.',
      );
    }
    if (state.loading && state.items.isEmpty) {
      return const KgweboLoadingState(message: 'Loading transactions');
    }
    if (state.error != null && state.items.isEmpty) {
      return KgweboEmptyState(
        icon: Icons.cloud_off_outlined,
        title: 'Could not load money',
        message: state.error!,
        actionLabel: 'Retry',
        onAction:
            () => ref.read(transactionsControllerProvider.notifier).refresh(),
      );
    }
    if (state.items.isEmpty) {
      return KgweboEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No money recorded yet',
        message:
            'Record a sale or an expense. Opening cash is a starting balance, so it is not listed here.',
        actionLabel: 'Record a sale',
        onAction: () => context.pushNamed(AppRoutes.recordSaleName),
      );
    }

    final queue = ref.watch(syncQueueControllerProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: KgweboSpacing.md),
          child: KgweboSyncNotice(),
        ),
        if (state.isStale)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: KgweboSpacing.md),
            child: KgweboStatusBanner(
              tone: KgweboBannerTone.warning,
              message:
                  'Showing saved transactions from this device. They may not include the latest changes.',
            ),
          )
        else if (state.error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: KgweboSpacing.md),
            child: KgweboStatusBanner(
              tone: KgweboBannerTone.warning,
              message: state.error!,
            ),
          ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(
              KgweboSpacing.md,
              KgweboSpacing.sm,
              KgweboSpacing.md,
              KgweboSpacing.xl + bottomInset,
            ),
            itemCount: state.items.length + (state.hasMore ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              if (index >= state.items.length) {
                return KgweboButton(
                  label: state.loadingMore ? 'Loading' : 'Load more',
                  variant: KgweboButtonVariant.text,
                  isLoading: state.loadingMore,
                  onPressed:
                      state.loadingMore
                          ? null
                          : () =>
                              ref
                                  .read(transactionsControllerProvider.notifier)
                                  .loadMore(),
                );
              }
              final transaction = state.items[index];
              final syncState = _syncState(queue.operations, transaction);
              return TransactionListItem(
                transaction: transaction,
                syncState: syncState,
                onTap:
                    () =>
                        transaction.pendingSync
                            ? context.pushNamed(AppRoutes.syncQueueName)
                            : context.pushNamed(
                              AppRoutes.transactionDetailsName,
                              pathParameters: {'transactionId': transaction.id},
                            ),
              );
            },
          ),
        ),
      ],
    );
  }

  OutboxState? _syncState(
    List<OutboxOperation> operations,
    BusinessTransaction transaction,
  ) {
    if (!transaction.pendingSync) {
      return null;
    }
    for (final operation in operations) {
      if (transaction.id == 'pending:${operation.operationId}') {
        return operation.state;
      }
    }
    return OutboxState.pending;
  }
}

class _RecordMoneyActions extends StatelessWidget {
  const _RecordMoneyActions();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: double.infinity,
      child: PopupMenuButton<String>(
        tooltip: 'Record money',
        padding: EdgeInsets.zero,
        position: PopupMenuPosition.under,
        onSelected: (value) {
          switch (value) {
            case 'sale':
              context.pushNamed(AppRoutes.recordSaleName);
            case 'expense':
              context.pushNamed(AppRoutes.recordExpenseName);
            case 'refund':
              context.pushNamed(AppRoutes.recordRefundName);
            case 'contribution':
              context.pushNamed(AppRoutes.recordContributionName);
            case 'withdrawal':
              context.pushNamed(AppRoutes.recordWithdrawalName);
          }
        },
        itemBuilder:
            (context) => const [
              PopupMenuItem(value: 'sale', child: Text('Record sale')),
              PopupMenuItem(value: 'expense', child: Text('Record expense')),
              PopupMenuDivider(),
              PopupMenuItem(value: 'refund', child: Text('Record refund')),
              PopupMenuItem(
                value: 'contribution',
                child: Text('Money you put in'),
              ),
              PopupMenuItem(
                value: 'withdrawal',
                child: Text('Money you took out'),
              ),
            ],
        child: SizedBox(
          width: double.infinity,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52, minWidth: 48),
            child: Material(
              color: KgweboColors.lime,
              elevation: 0,
              shadowColor: Colors.transparent,
              borderRadius: KgweboRadii.borderPill,
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: KgweboSpacing.lg,
                  vertical: KgweboSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Record',
                      style: textTheme.labelLarge?.copyWith(
                        color: KgweboColors.onLime,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.expand_more,
                      size: 20,
                      color: KgweboColors.onLime,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
