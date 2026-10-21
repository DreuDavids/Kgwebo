import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/kgwebo_spacing.dart';
import '../../../../shared/widgets/kgwebo_button.dart';
import '../../../../shared/widgets/kgwebo_empty_state.dart';
import '../../../../shared/widgets/kgwebo_section_heading.dart';
import '../../../transactions/presentation/widgets/transaction_list_item.dart';
import '../../application/dashboard_finance_controller.dart';

class DashboardRecent extends ConsumerWidget {
  const DashboardRecent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardFinanceControllerProvider);
    if (state.isPreview || state.loading) {
      return const SizedBox.shrink();
    }
    if (state.recent.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KgweboSectionHeading(
            title: 'Recent transactions',
            subtitle: 'Nothing recorded yet.',
          ),
          KgweboEmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'Start with a sale or expense',
            message:
                'A zero here means you have not saved transactions, not that the business made no money outside Kgwebo.',
            actionLabel: 'Record a sale',
            onAction: () => context.pushNamed(AppRoutes.recordSaleName),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KgweboSectionHeading(
          title: 'Recent transactions',
          subtitle: 'Latest confirmed records.',
        ),
        const SizedBox(height: KgweboSpacing.sm),
        for (final transaction in state.recent) ...[
          TransactionListItem(
            transaction: transaction,
            onTap:
                () => context.pushNamed(
                  AppRoutes.transactionDetailsName,
                  pathParameters: {'transactionId': transaction.id},
                ),
          ),
          const SizedBox(height: KgweboSpacing.sm),
        ],
        KgweboButton(
          label: 'View all transactions',
          variant: KgweboButtonVariant.text,
          onPressed: () => context.goNamed(AppRoutes.transactionsName),
        ),
      ],
    );
  }
}
