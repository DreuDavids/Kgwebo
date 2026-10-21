import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/kgwebo_spacing.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../shared/widgets/kgwebo_button.dart';
import '../../../../shared/widgets/kgwebo_section_heading.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KgweboSectionHeading(
          title: 'Start here',
          subtitle:
              'These open the matching section. Recording is not enabled yet.',
        ),
        const SizedBox(height: KgweboSpacing.sm),
        KgweboResponsiveGrid(
          columnsForWidth: (width) => width >= 520 ? 2 : 1,
          children: [
            KgweboButton(
              label: 'Record a sale',
              icon: Icons.add_card_outlined,
              expanded: true,
              onPressed: () => context.goNamed(AppRoutes.transactionsName),
            ),
            KgweboButton(
              label: 'Record an expense',
              icon: Icons.outbox_outlined,
              variant: KgweboButtonVariant.secondary,
              expanded: true,
              onPressed: () => context.goNamed(AppRoutes.transactionsName),
            ),
            KgweboButton(
              label: 'Add a product',
              icon: Icons.inventory_2_outlined,
              variant: KgweboButtonVariant.secondary,
              expanded: true,
              onPressed: () => context.goNamed(AppRoutes.productsName),
            ),
            KgweboButton(
              label: 'View cash flow',
              icon: Icons.waterfall_chart_outlined,
              variant: KgweboButtonVariant.secondary,
              expanded: true,
              onPressed: () => context.goNamed(AppRoutes.cashFlowName),
            ),
          ],
        ),
      ],
    );
  }
}
