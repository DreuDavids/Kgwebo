import 'package:flutter/material.dart';

import '../../../../app/theme/kgwebo_colors.dart';
import '../../../../app/theme/kgwebo_spacing.dart';
import '../../../../core/finance/recommendation_rules.dart';
import '../../../../shared/widgets/kgwebo_button.dart';
import '../../../../shared/widgets/kgwebo_soft_card.dart';
import '../../domain/visible_recommendation.dart';
import '../recommendation_navigation.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.item,
    this.onDismiss,
    this.compact = false,
  });

  final VisibleRecommendation item;
  final VoidCallback? onDismiss;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return KgweboSoftCard(
      padding: const EdgeInsets.all(KgweboSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _severityLabel(item.severity),
            style: textTheme.labelLarge?.copyWith(
              color:
                  item.severity == RecommendationSeverity.high
                      ? KgweboColors.amber
                      : KgweboColors.inkMuted,
            ),
          ),
          const SizedBox(height: KgweboSpacing.xs),
          Text(
            item.title,
            style: textTheme.titleMedium?.copyWith(
              color: KgweboColors.ink,
              height: 1.25,
            ),
          ),
          const SizedBox(height: KgweboSpacing.sm),
          Text(
            item.explanation,
            style: textTheme.bodyMedium?.copyWith(
              color: KgweboColors.inkMuted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: KgweboSpacing.sm),
          Text(
            item.evidence,
            style: textTheme.bodySmall?.copyWith(
              color: KgweboColors.ink,
              height: 1.45,
            ),
          ),
          const SizedBox(height: KgweboSpacing.md),
          Wrap(
            spacing: KgweboSpacing.sm,
            runSpacing: KgweboSpacing.sm,
            children: [
              KgweboButton(
                label: item.suggestedAction,
                onPressed:
                    () => openRecommendationDestination(
                      context,
                      item.destination,
                    ),
              ),
              if (onDismiss != null)
                KgweboButton(
                  label: 'Dismiss',
                  variant: KgweboButtonVariant.text,
                  onPressed: onDismiss,
                ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: KgweboSpacing.sm),
            Text(
              'This is based on saved business records. It is not professional accounting, tax or investment advice.',
              style: textTheme.bodySmall?.copyWith(
                color: KgweboColors.inkMuted,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _severityLabel(RecommendationSeverity severity) {
    return switch (severity) {
      RecommendationSeverity.high => 'Needs attention',
      RecommendationSeverity.medium => 'Review',
      RecommendationSeverity.low => 'Records gap',
    };
  }
}
