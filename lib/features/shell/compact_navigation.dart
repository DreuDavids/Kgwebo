import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/kgwebo_colors.dart';
import '../../app/theme/kgwebo_elevation.dart';
import '../../app/theme/kgwebo_radii.dart';
import '../../app/theme/kgwebo_spacing.dart';
import 'app_destinations.dart';

class CompactNavigation extends StatelessWidget {
  const CompactNavigation({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final selected = AppDestinationX.compactIndexFor(
      navigationShell.currentIndex,
    );
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: KgweboColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(KgweboRadii.lg),
        ),
        boxShadow: KgweboElevation.soft,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            KgweboSpacing.xs,
            KgweboSpacing.xs,
            KgweboSpacing.xs,
            KgweboSpacing.xs,
          ),
          child: Row(
            children: [
              for (
                var index = 0;
                index < AppDestinationX.compactDestinations.length;
                index++
              )
                Expanded(
                  child: _NavItem(
                    destination: AppDestinationX.compactDestinations[index],
                    selected: index == selected,
                    onTap: () {
                      final destination =
                          AppDestinationX.compactDestinations[index];
                      navigationShell.goBranch(
                        destination.branchIndex,
                        initialLocation:
                            destination.branchIndex ==
                            navigationShell.currentIndex,
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final AppDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? KgweboColors.ink : KgweboColors.inkMuted;
    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: KgweboRadii.borderLg,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: KgweboSpacing.xs),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: selected ? KgweboColors.ink : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(KgweboSpacing.xs),
                      child: Icon(
                        selected ? destination.selectedIcon : destination.icon,
                        color: selected ? KgweboColors.lime : color,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    destination.compactLabel,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: color),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
