import 'package:flutter/material.dart';

import '../../app/theme/kgwebo_colors.dart';
import '../../app/theme/kgwebo_radii.dart';
import '../../app/theme/kgwebo_spacing.dart';
import '../../app/theme/kgwebo_typography.dart';

/// Display tile for a labelled metric. Values that are not live business
/// data must say so through [caption] and [isPreview].
class KgweboMetricCard extends StatelessWidget {
  const KgweboMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.caption,
    this.icon,
    this.isPreview = false,
  });

  final String label;
  final String value;
  final String? caption;
  final IconData? icon;
  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      label: [
        label,
        value,
        if (caption != null) caption,
        if (isPreview) 'Preview, not live business data',
      ].join('. '),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: KgweboColors.surface,
          borderRadius: KgweboRadii.borderMd,
          border: Border.all(color: KgweboColors.line),
        ),
        child: Padding(
          padding: const EdgeInsets.all(KgweboSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: KgweboColors.teal),
                    const SizedBox(width: KgweboSpacing.xs),
                  ],
                  Expanded(
                    child: Text(
                      label,
                      style: textTheme.labelMedium?.copyWith(
                        color: KgweboColors.inkMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: KgweboSpacing.sm),
              Text(
                value,
                style: textTheme.headlineLarge?.copyWith(
                  fontFamily: KgweboTypography.serif,
                ),
              ),
              if (caption != null) ...[
                const SizedBox(height: KgweboSpacing.xs),
                Text(caption!, style: textTheme.bodySmall),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
