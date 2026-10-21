import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/kgwebo_spacing.dart';
import '../../../../shared/widgets/kgwebo_pill_row.dart';
import '../../../../shared/widgets/kgwebo_section_heading.dart';
import '../../../../shared/widgets/kgwebo_soft_card.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KgweboSectionHeading(
          title: 'Start here',
          subtitle: 'Record activity. Totals update after a confirmed save.',
        ),
        const SizedBox(height: KgweboSpacing.sm),
        KgweboSoftCard(
          padding: const EdgeInsets.symmetric(vertical: KgweboSpacing.xs),
          child: Column(
            children: [
              KgweboPillRow(
                icon: Icons.add_card_outlined,
                title: 'Record a sale',
                trailingLabel: 'Go',
                trailingFilled: true,
                onTap: () => context.pushNamed(AppRoutes.recordSaleName),
              ),
              KgweboPillRow(
                icon: Icons.outbox_outlined,
                title: 'Record an expense',
                trailingLabel: 'Go',
                onTap: () => context.pushNamed(AppRoutes.recordExpenseName),
              ),
              KgweboPillRow(
                icon: Icons.receipt_long_outlined,
                title: 'View transactions',
                trailingLabel: 'Explore',
                onTap: () => context.goNamed(AppRoutes.transactionsName),
              ),
              KgweboPillRow(
                icon: Icons.event_outlined,
                title: 'Add a commitment',
                trailingLabel: 'Go',
                onTap: () => context.pushNamed(AppRoutes.recordObligationName),
              ),
              KgweboPillRow(
                icon: Icons.inventory_2_outlined,
                title: 'Add a product',
                trailingLabel: 'Explore',
                onTap: () => context.goNamed(AppRoutes.productsName),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
