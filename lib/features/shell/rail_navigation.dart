import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/kgwebo_colors.dart';
import '../../app/theme/kgwebo_spacing.dart';
import '../../app/theme/kgwebo_typography.dart';
import 'app_destinations.dart';

class RailNavigation extends StatelessWidget {
  const RailNavigation({
    super.key,
    required this.navigationShell,
    required this.extended,
  });

  final StatefulNavigationShell navigationShell;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final current = AppDestinationX.fromBranchIndex(
      navigationShell.currentIndex,
    );
    final selectedIndex =
        current.shownInRail
            ? AppDestinationX.railDestinations.indexOf(current)
            : 0;

    return SizedBox(
      width: extended ? 220 : 92,
      child: ColoredBox(
        color: KgweboColors.canvas,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                extended ? KgweboSpacing.md : KgweboSpacing.xs,
                KgweboSpacing.lg,
                KgweboSpacing.sm,
                KgweboSpacing.sm,
              ),
              child: Align(
                alignment: extended ? Alignment.centerLeft : Alignment.center,
                child: Text(
                  extended ? 'Kgwebo' : 'K',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontFamily: extended ? null : KgweboTypography.serif,
                    color: KgweboColors.ink,
                  ),
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: NavigationRail(
                          extended: extended,
                          selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
                          labelType:
                              extended
                                  ? NavigationRailLabelType.none
                                  : NavigationRailLabelType.all,
                          minWidth: 88,
                          minExtendedWidth: 208,
                          groupAlignment: -1,
                          onDestinationSelected: (index) {
                            final destination =
                                AppDestinationX.railDestinations[index];
                            navigationShell.goBranch(
                              destination.branchIndex,
                              initialLocation:
                                  destination.branchIndex ==
                                  navigationShell.currentIndex,
                            );
                          },
                          destinations: [
                            for (final destination
                                in AppDestinationX.railDestinations)
                              NavigationRailDestination(
                                icon: Icon(
                                  destination.icon,
                                  semanticLabel: destination.label,
                                ),
                                selectedIcon: Icon(
                                  destination.selectedIcon,
                                  semanticLabel: destination.label,
                                ),
                                label: Text(destination.label),
                                padding: const EdgeInsets.symmetric(
                                  vertical: KgweboSpacing.xxs,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
