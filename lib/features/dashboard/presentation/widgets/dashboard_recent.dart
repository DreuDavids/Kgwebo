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
    if (state.isPreview) {
      return const KgweboEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Nothing recorded yet',
        message: 'Sign in to add sales and expenses.',
      );
    }
    if (state.loading) {
      return const SizedBox.shrink();
    }
    if (state.recent.isEmpty) {
      return const KgweboEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No money recorded yet',
        message:
            'Add a sale or expense above. Opening cash is not listed here.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KgweboSectionHeading(
          title: 'Recent money',
          subtitle: 'Latest confirmed records. Tap one to open it.',
        ),
        const SizedBox(height: KgweboSpacing.sm),
        for (final transaction in state.recent.take(3)) ...[
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
          label: 'See all',
          variant: KgweboButtonVariant.text,
          onPressed: () => context.goNamed(AppRoutes.transactionsName),
        ),
      ],
    );
  }
}
