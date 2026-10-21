import 'package:flutter/material.dart';

import '../../../../app/theme/kgwebo_colors.dart';
import '../../../../app/theme/kgwebo_radii.dart';
import '../../../../app/theme/kgwebo_spacing.dart';

enum DashboardHomeTab { overview, records, outlook }

extension DashboardHomeTabLabel on DashboardHomeTab {
  String get label {
    return switch (this) {
      DashboardHomeTab.overview => 'Overview',
      DashboardHomeTab.records => 'Records',
      DashboardHomeTab.outlook => 'Outlook',
    };
  }
}

class DashboardHomeTabs extends StatelessWidget {
  const DashboardHomeTabs({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const double height = 64;

  final DashboardHomeTab selected;
  final ValueChanged<DashboardHomeTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KgweboSpacing.md,
        KgweboSpacing.xs,
        KgweboSpacing.md,
        KgweboSpacing.xs,
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: KgweboColors.surfaceMuted,
          borderRadius: KgweboRadii.borderPill,
        ),
        child: Padding(
          padding: const EdgeInsets.all(KgweboSpacing.xxs),
          child: Row(
            children: [
              for (final tab in DashboardHomeTab.values)
                Expanded(
                  child: _HomeTabChip(
                    key: ValueKey('dashboard-tab-${tab.name}'),
                    label: tab.label,
                    selected: tab == selected,
                    onTap: () => onSelected(tab),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTabChip extends StatelessWidget {
  const _HomeTabChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected ? KgweboColors.ink : Colors.transparent,
        shape: const StadiumBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: KgweboSpacing.xs),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
