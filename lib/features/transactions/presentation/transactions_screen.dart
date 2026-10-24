import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
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
      appBar: AppBar(
        title: const Text('Money'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'More money types',
            onSelected: (value) {
              switch (value) {
                case 'refund':
                  context.pushNamed(AppRoutes.recordRefundName);
                case 'contribution':
                  context.pushNamed(AppRoutes.recordContributionName);
                case 'withdrawal':
                  context.pushNamed(AppRoutes.recordWithdrawalName);
                default:
                  break;
              }
            },
            itemBuilder:
                (context) => const [
                  PopupMenuItem(
                    value: 'refund',
                    child: Text('Record a refund'),
                  ),
                  PopupMenuItem(
                    value: 'contribution',
                    child: Text('Money you put in'),
                  ),
                  PopupMenuItem(
                    value: 'withdrawal',
                    child: Text('Money you took out'),
                  ),
                ],
          ),
        ],
      ),
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
              const SizedBox(height: KgweboSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: KgweboSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: KgweboButton(
                        label: 'Record a sale',
                        icon: Icons.add_card_outlined,
                        expanded: true,
                        onPressed:
                            () => context.pushNamed(AppRoutes.recordSaleName),
                      ),
                    ),
                    const SizedBox(width: KgweboSpacing.sm),
                    Expanded(
                      child: KgweboButton(
                        label: 'Record an expense',
                        icon: Icons.outbox_outlined,
                        variant: KgweboButtonVariant.secondary,
                        expanded: true,
                        onPressed:
                            () =>
                                context.pushNamed(AppRoutes.recordExpenseName),
                      ),
                    ),
                  ],
                ),
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
