import 'package:flutter/material.dart';

import '../../../../app/theme/kgwebo_colors.dart';
import '../../../../app/theme/kgwebo_spacing.dart';
import '../../../../core/finance/cash_forecast.dart';

class ForecastHorizonChips extends StatelessWidget {
  const ForecastHorizonChips({
    super.key,
    required this.selected,
    required this.onSelected,
    this.enabled = true,
  });

  final ForecastHorizon selected;
  final ValueChanged<ForecastHorizon> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: KgweboSpacing.xs,
      runSpacing: KgweboSpacing.xs,
      children: [
        for (final horizon in ForecastHorizon.values)
          _HorizonChip(
            label: horizon.label,
            selected: horizon == selected,
            enabled: enabled,
            onTap: () => onSelected(horizon),
          ),
      ],
    );
  }
}

class _HorizonChip extends StatelessWidget {
  const _HorizonChip({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: '$label forecast',
      child: Material(
        color: selected ? KgweboColors.ink : KgweboColors.surface,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? KgweboColors.ink : KgweboColors.line,
          ),
        ),
        child: InkWell(
          onTap: enabled ? onTap : null,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: KgweboSpacing.md,
              vertical: KgweboSpacing.sm,
            ),
            child: Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: selected ? KgweboColors.onInk : KgweboColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
