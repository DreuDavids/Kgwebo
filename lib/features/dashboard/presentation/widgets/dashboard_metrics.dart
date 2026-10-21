import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive_layout.dart';
import '../../../../shared/widgets/kgwebo_metric_card.dart';
import '../../../../shared/widgets/kgwebo_section_heading.dart';

class DashboardMetrics extends StatelessWidget {
  const DashboardMetrics({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KgweboSectionHeading(
          title: 'What you will track',
          subtitle: 'Layout preview — not live business figures.',
        ),
        SizedBox(height: 12),
        KgweboResponsiveGrid(
          children: [
            KgweboMetricCard(
              label: 'Cash position',
              value: '—',
              caption: 'Opens after you record a starting balance.',
              icon: Icons.account_balance_wallet_outlined,
              isPreview: true,
            ),
            KgweboMetricCard(
              label: 'Sales this period',
              value: '—',
              caption: 'Appears from saved sales, not estimates.',
              icon: Icons.trending_up,
              isPreview: true,
            ),
            KgweboMetricCard(
              label: 'Expenses this period',
              value: '—',
              caption: 'Paid costs only. Planned bills stay separate.',
              icon: Icons.south_west,
              isPreview: true,
            ),
            KgweboMetricCard(
              label: 'Estimated profit',
              value: '—',
              caption: 'Sales minus recognised costs for the period.',
              icon: Icons.insights_outlined,
              isPreview: true,
            ),
          ],
        ),
      ],
    );
  }
}
