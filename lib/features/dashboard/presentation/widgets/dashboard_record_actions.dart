import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/kgwebo_spacing.dart';
import '../../../../shared/widgets/kgwebo_button.dart';

class DashboardRecordActions extends StatelessWidget {
  const DashboardRecordActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KgweboButton(
          label: 'Record a sale',
          icon: Icons.add_card_outlined,
          expanded: true,
          onPressed: () => context.pushNamed(AppRoutes.recordSaleName),
        ),
        const SizedBox(height: KgweboSpacing.sm),
        KgweboButton(
          label: 'Record an expense',
          icon: Icons.outbox_outlined,
          variant: KgweboButtonVariant.secondary,
          expanded: true,
          onPressed: () => context.pushNamed(AppRoutes.recordExpenseName),
        ),
      ],
    );
  }
}
