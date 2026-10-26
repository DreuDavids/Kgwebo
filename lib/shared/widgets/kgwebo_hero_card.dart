import 'package:flutter/material.dart';

import '../../app/theme/kgwebo_colors.dart';
import '../../app/theme/kgwebo_radii.dart';
import '../../app/theme/kgwebo_spacing.dart';
import 'kgwebo_sparkline.dart';

class KgweboCircleAction {
  const KgweboCircleAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool emphasized;
}

/// Black rounded hero used for primary totals.
class KgweboHeroCard extends StatelessWidget {
  const KgweboHeroCard({
    super.key,
    required this.label,
    required this.value,
    this.caption,
    this.sparkline = const [],
    this.actions = const [],
  });

  final String label;
  final String value;
  final String? caption;
  final List<double> sparkline;
  final List<KgweboCircleAction> actions;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      label: [label, value, if (caption != null) caption].join('. '),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: KgweboColors.ink,
          borderRadius: KgweboRadii.borderXl,
        ),
        child: Padding(
          padding: const EdgeInsets.all(KgweboSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  color: KgweboColors.inkFaint,
                ),
              ),
              const SizedBox(height: KgweboSpacing.xs),
              Text(
                value,
                style: textTheme.displayMedium?.copyWith(
                  color: KgweboColors.onInk,
                ),
              ),
              if (caption != null) ...[
                const SizedBox(height: KgweboSpacing.xs),
                Text(
                  caption!,
                  style: textTheme.bodySmall?.copyWith(
                    color: KgweboColors.inkFaint,
                  ),
                ),
              ],
              if (sparkline.length >= 2) ...[
                const SizedBox(height: KgweboSpacing.md),
                KgweboSparkline(values: sparkline),
              ],
              if (actions.isNotEmpty) ...[
                const SizedBox(height: KgweboSpacing.lg),
                Row(
                  children: [
                    for (var i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(width: KgweboSpacing.sm),
                      Expanded(child: _HeroAction(action: actions[i])),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Lime highlight banner for a secondary total.
class KgweboHighlightCard extends StatelessWidget {
  const KgweboHighlightCard({
    super.key,
    required this.label,
    required this.value,
    this.caption,
    this.chart,
  });

  final String label;
  final String value;
  final String? caption;
  final Widget? chart;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      label: [label, value, if (caption != null) caption].join('. '),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: KgweboColors.lime,
          borderRadius: KgweboRadii.borderXl,
        ),
        child: Padding(
          padding: const EdgeInsets.all(KgweboSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  color: KgweboColors.onLime,
                ),
              ),
              const SizedBox(height: KgweboSpacing.xs),
              Text(
                value,
                style: textTheme.displaySmall?.copyWith(
                  color: KgweboColors.onLime,
                ),
              ),
              if (caption != null) ...[
                const SizedBox(height: KgweboSpacing.xs),
                Text(
                  caption!,
                  style: textTheme.bodySmall?.copyWith(
                    color: KgweboColors.onLime,
                  ),
                ),
              ],
              if (chart != null) ...[
                const SizedBox(height: KgweboSpacing.md),
                chart!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroAction extends StatelessWidget {
  const _HeroAction({required this.action});

  final KgweboCircleAction action;

  @override
  Widget build(BuildContext context) {
    final well = action.emphasized ? KgweboColors.lime : KgweboColors.heroWell;
    final iconColor =
        action.emphasized ? KgweboColors.onLime : KgweboColors.onInk;
    return Semantics(
      button: true,
      label: action.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: action.onTap,
          borderRadius: KgweboRadii.borderLg,
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: well, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Icon(action.icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: KgweboSpacing.xs),
              Text(
                action.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: KgweboColors.onInk),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
