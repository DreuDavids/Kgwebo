import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../../app/theme/kgwebo_colors.dart';
import '../../../app/theme/kgwebo_spacing.dart';
import '../../../core/finance/business_calendar.dart';
import '../../../core/finance/ledger_entry.dart';
import '../../../core/money/money_formatter.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../shared/widgets/kgwebo_button.dart';
import '../../../shared/widgets/kgwebo_hero_card.dart';
import '../../../shared/widgets/kgwebo_soft_card.dart';
import '../../../shared/widgets/kgwebo_empty_state.dart';
import '../../../shared/widgets/kgwebo_loading_state.dart';
import '../../../shared/widgets/kgwebo_status_banner.dart';
import '../../authentication/application/session_controller.dart';
import '../../authentication/domain/app_session.dart';
import '../../authentication/domain/auth_failure.dart';
import '../application/transaction_tick.dart';
import '../domain/business_transaction.dart';
import '../domain/payment_method.dart';
import '../domain/transaction_categories.dart';
import 'widgets/transaction_type_style.dart';

class TransactionDetailsScreen extends ConsumerStatefulWidget {
  const TransactionDetailsScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  ConsumerState<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState
    extends ConsumerState<TransactionDetailsScreen> {
  BusinessTransaction? _transaction;
  String? _error;
  bool _loading = true;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final session = ref.read(appSessionProvider);
    if (session is! AppSessionReady) {
      setState(() {
        _loading = false;
        _error = 'Sign in to view this transaction.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final loaded = await ref
          .read(transactionRepositoryProvider)
          .findById(
            ownerId: session.user.id,
            businessId: session.business.id,
            transactionId: widget.transactionId,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _transaction = loaded;
        _loading = false;
        if (loaded == null) {
          _error = 'This transaction was not found.';
        }
      });
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = error.message;
      });
    }
  }

  Future<void> _confirmDelete() async {
    final transaction = _transaction;
    if (transaction == null || _deleting) {
      return;
    }
    final amount = MoneyFormatter.formatMinor(
      transaction.amountMinor,
      currencyCode: transaction.currencyCode,
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete this transaction?'),
            content: Text(
              'This permanently removes the ${TransactionTypeStyle.label(transaction.type).toLowerCase()} of $amount from your records and updates your totals. This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Keep it'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    final session = ref.read(appSessionProvider);
    if (session is! AppSessionReady) {
      return;
    }
    setState(() => _deleting = true);
    try {
      await ref
          .read(transactionRepositoryProvider)
          .delete(
            ownerId: session.user.id,
            businessId: session.business.id,
            transactionId: transaction.id,
          );
      if (!mounted) {
        return;
      }
      bumpTransactionTick(ref);
      context.goNamed(AppRoutes.transactionsName);
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _deleting = false;
        _error = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction')),
      body: SafeArea(child: KgweboFilledBody(child: _buildBody(context))),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const KgweboLoadingState(message: 'Loading transaction');
    }
    final transaction = _transaction;
    if (transaction == null) {
      return KgweboEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Transaction not found',
        message:
            _error ?? 'It may have been deleted or belong to another business.',
        actionLabel: 'Back to history',
        onAction: () => context.goNamed(AppRoutes.transactionsName),
      );
    }

    final textTheme = Theme.of(context).textTheme;
    final wall = BusinessCalendar.gaboroneWallTime(transaction.occurredAt);
    final type = transaction.type;
    return ListView(
      padding: const EdgeInsets.all(KgweboSpacing.md),
      children: [
        if (_error != null) ...[
          KgweboStatusBanner(tone: KgweboBannerTone.warning, message: _error!),
          const SizedBox(height: KgweboSpacing.md),
        ],
        KgweboHeroCard(
          label: TransactionTypeStyle.label(type),
          value: MoneyFormatter.formatMinor(
            transaction.amountMinor,
            currencyCode: transaction.currencyCode,
          ),
        ),
        const SizedBox(height: KgweboSpacing.md),
        KgweboSoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _row(
                'Category',
                TransactionCategories.labelFor(type, transaction.category),
              ),
              _row('Date', DateFormat.yMMMEd().format(wall)),
              _row('Payment method', transaction.paymentMethod.label),
              _row(
                'Payment status',
                transaction.paymentStatus == PaymentStatus.paid
                    ? 'Paid'
                    : 'Unpaid',
              ),
              if (transaction.description != null &&
                  transaction.description!.trim().isNotEmpty)
                _row('Note', transaction.description!),
            ],
          ),
        ),
        const SizedBox(height: KgweboSpacing.xl),
        KgweboButton(
          label: 'Edit',
          expanded: true,
          onPressed:
              _deleting
                  ? null
                  : () => context.pushNamed(
                    AppRoutes.transactionEditName,
                    pathParameters: {'transactionId': transaction.id},
                    extra: type,
                  ),
        ),
        const SizedBox(height: KgweboSpacing.sm),
        KgweboButton(
          label: 'Delete',
          variant: KgweboButtonVariant.secondary,
          expanded: true,
          isLoading: _deleting,
          onPressed: _deleting ? null : _confirmDelete,
        ),
        const SizedBox(height: KgweboSpacing.md),
        Text(
          'Deleting removes this row from your history and from the totals. There is no hidden archive.',
          style: textTheme.bodySmall?.copyWith(color: KgweboColors.inkMuted),
        ),
      ],
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KgweboSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: KgweboColors.inkMuted),
          ),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}
