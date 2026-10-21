import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/kgwebo_colors.dart';
import '../../../../app/theme/kgwebo_radii.dart';
import '../../../../app/theme/kgwebo_spacing.dart';
import '../../../../app/theme/kgwebo_typography.dart';
import '../../../../shared/widgets/kgwebo_button.dart';
import '../../../../shared/widgets/kgwebo_section_heading.dart';

class DashboardOutlook extends StatelessWidget {
  const DashboardOutlook({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KgweboSectionHeading(
          title: 'Cash-flow outlook',
          subtitle: 'Forecasts will use your records, never invented sales.',
        ),
        const SizedBox(height: KgweboSpacing.sm),
        DecoratedBox(
          decoration: BoxDecoration(
            color: KgweboColors.surface,
            borderRadius: KgweboRadii.borderMd,
            border: Border.all(color: KgweboColors.line),
          ),
          child: Padding(
            padding: const EdgeInsets.all(KgweboSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Know whether cash covers what is coming.',
                  style: textTheme.headlineSmall?.copyWith(
                    fontFamily: KgweboTypography.serif,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: KgweboSpacing.sm),
                Text(
                  'When you add transactions and upcoming bills, Kgwebo will '
                  'project the next 7, 14 or 30 days and explain any shortfall '
                  'in plain language. Nothing is forecast until those records exist.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: KgweboColors.inkMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: KgweboSpacing.md),
                KgweboButton(
                  label: 'Open cash flow',
                  variant: KgweboButtonVariant.text,
                  onPressed: () => context.goNamed(AppRoutes.cashFlowName),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
