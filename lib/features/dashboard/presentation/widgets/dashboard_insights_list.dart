import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/kgwebo_spacing.dart';
import '../../../../core/finance/dashboard_insights.dart';
import '../../../../shared/widgets/kgwebo_section_heading.dart';
import '../../../../shared/widgets/kgwebo_status_banner.dart';
import '../../application/dashboard_finance_controller.dart';

class DashboardInsightsList extends ConsumerWidget {
  const DashboardInsightsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardFinanceControllerProvider);
    final insights = [
      for (final insight in state.insights)
        if (insight.kind != DashboardInsightKind.incompleteHistory) insight,
    ];
    if (insights.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KgweboSectionHeading(
          title: 'What this period shows',
          subtitle:
              'These notices use saved records only. Nothing is invented.',
        ),
        const SizedBox(height: KgweboSpacing.sm),
        for (final insight in insights) ...[
          KgweboStatusBanner(
            tone:
                insight.kind == DashboardInsightKind.overdueCommitments ||
                        insight.kind == DashboardInsightKind.expensesExceedSales
                    ? KgweboBannerTone.warning
                    : KgweboBannerTone.info,
            message: '${insight.title} ${insight.evidence}',
          ),
          const SizedBox(height: KgweboSpacing.sm),
        ],
      ],
    );
  }
}
