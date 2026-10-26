import 'package:flutter/material.dart';

import '../../../../app/theme/kgwebo_colors.dart';
import '../../../../app/theme/kgwebo_spacing.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../shared/widgets/kgwebo_metric_card.dart';
import '../../../../shared/widgets/kgwebo_section_heading.dart';
import '../../../../shared/widgets/kgwebo_soft_card.dart';
import '../../application/report_copy.dart';
import '../../domain/report_document.dart';

class ReportPreview extends StatelessWidget {
  const ReportPreview({super.key, required this.document});

  final ReportDocument document;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KgweboSoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                document.businessName,
                style: textTheme.headlineSmall?.copyWith(
                  color: KgweboColors.ink,
                ),
              ),
              const SizedBox(height: KgweboSpacing.xxs),
              Text(
                [
                  if (document.businessType.isNotEmpty) document.businessType,
                  if (document.countryLabel.isNotEmpty) document.countryLabel,
                  document.currencyCode,
                ].join(' · '),
                style: textTheme.bodyMedium?.copyWith(
                  color: KgweboColors.inkMuted,
                ),
              ),
              if (document.description != null) ...[
                const SizedBox(height: KgweboSpacing.xs),
                Text(document.description!, style: textTheme.bodyMedium),
              ],
              const SizedBox(height: KgweboSpacing.sm),
              Text(
                document.periodLabel,
                style: textTheme.titleMedium?.copyWith(
                  color: KgweboColors.success,
                ),
              ),
              Text(
                'Generated ${ReportCopy.generatedOn(document)}',
                style: textTheme.bodySmall?.copyWith(
                  color: KgweboColors.inkMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: KgweboSpacing.lg),
        const KgweboSectionHeading(
          title: 'Financial summary',
          subtitle: 'Figures match the same engine as Home.',
        ),
        const SizedBox(height: KgweboSpacing.sm),
        KgweboResponsiveGrid(
          children: [
            for (final metric in ReportCopy.financialMetrics(document))
              KgweboMetricCard(
                label: metric.label,
                value: metric.value,
                caption: metric.caption,
              ),
          ],
        ),
        const SizedBox(height: KgweboSpacing.lg),
        const KgweboSectionHeading(title: 'Transaction counts'),
        const SizedBox(height: KgweboSpacing.sm),
        KgweboResponsiveGrid(
          children: [
            for (final metric in ReportCopy.counts(document))
              KgweboMetricCard(label: metric.label, value: metric.value),
          ],
        ),
        if (document.notes.isNotEmpty) ...[
          const SizedBox(height: KgweboSpacing.lg),
          const KgweboSectionHeading(title: 'Notes'),
          const SizedBox(height: KgweboSpacing.sm),
          KgweboSoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final note in document.notes) ...[
                  Text(note, style: textTheme.bodyMedium),
                  const SizedBox(height: KgweboSpacing.sm),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: KgweboSpacing.lg),
        KgweboSoftCard(
          color: KgweboColors.surfaceMuted,
          child: Text(
            document.disclaimer,
            style: textTheme.bodySmall?.copyWith(height: 1.45),
          ),
        ),
      ],
    );
  }
}
