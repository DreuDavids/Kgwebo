import 'package:flutter/material.dart';

import '../../app/theme/kgwebo_colors.dart';
import '../../app/theme/kgwebo_spacing.dart';
import 'kgwebo_soft_card.dart';

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
      child: KgweboSoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: KgweboColors.surfaceMuted,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 16, color: KgweboColors.ink),
                  ),
                  const SizedBox(width: KgweboSpacing.sm),
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
              style: textTheme.headlineLarge?.copyWith(color: KgweboColors.ink),
            ),
            if (caption != null) ...[
              const SizedBox(height: KgweboSpacing.xs),
              Text(caption!, style: textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
