import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_destinations.dart';

class CompactNavigation extends StatelessWidget {
  const CompactNavigation({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final selected = AppDestinationX.compactIndexFor(
      navigationShell.currentIndex,
    );
    return NavigationBar(
      selectedIndex: selected,
      onDestinationSelected: (index) {
        final destination = AppDestinationX.compactDestinations[index];
        navigationShell.goBranch(
          destination.branchIndex,
          initialLocation:
              destination.branchIndex == navigationShell.currentIndex,
        );
      },
      destinations: [
        for (final destination in AppDestinationX.compactDestinations)
          NavigationDestination(
            icon: Icon(destination.icon, semanticLabel: destination.label),
            selectedIcon: Icon(
              destination.selectedIcon,
              semanticLabel: destination.label,
            ),
            label: destination.compactLabel,
            tooltip: destination.label,
          ),
      ],
    );
  }
}
