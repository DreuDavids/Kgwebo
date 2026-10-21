import 'package:flutter/material.dart';

import '../../app/theme/kgwebo_colors.dart';
import '../../app/theme/kgwebo_radii.dart';
import '../../app/theme/kgwebo_spacing.dart';

/// Icon-leading action or summary row.
class KgweboPillRow extends StatelessWidget {
  const KgweboPillRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailingLabel,
    this.trailingFilled = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailingLabel;
  final bool trailingFilled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KgweboSpacing.md,
        vertical: KgweboSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: KgweboColors.surfaceMuted,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: KgweboColors.ink),
          ),
          const SizedBox(width: KgweboSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    color: KgweboColors.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: textTheme.bodySmall?.copyWith(
                      color: KgweboColors.inkMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (trailingLabel != null) ...[
            const SizedBox(width: KgweboSpacing.sm),
            _TrailingChip(label: trailingLabel!, filled: trailingFilled),
          ],
        ],
      ),
    );

    return Semantics(
      button: onTap != null,
      label: [
        title,
        if (subtitle != null) subtitle,
        if (trailingLabel != null) trailingLabel,
      ].join('. '),
      child: Material(
        color: KgweboColors.surface,
        borderRadius: KgweboRadii.borderLg,
        child: InkWell(
          onTap: onTap,
          borderRadius: KgweboRadii.borderLg,
          child: row,
        ),
      ),
    );
  }
}

class _TrailingChip extends StatelessWidget {
  const _TrailingChip({required this.label, required this.filled});

  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 32),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: filled ? KgweboColors.lime : KgweboColors.surfaceMuted,
          borderRadius: KgweboRadii.borderPill,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KgweboSpacing.sm,
            vertical: KgweboSpacing.xxs,
          ),
          child: Center(
            child: Text(
              label,
              style: textTheme.labelMedium?.copyWith(color: KgweboColors.ink),
            ),
          ),
        ),
      ),
    );
  }
}
