import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/kgwebo_colors.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/responsive/window_size_class.dart';
import 'compact_navigation.dart';
import 'rail_navigation.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final sizeClass = KgweboBreakpoints.of(context);
    return switch (sizeClass) {
      WindowSizeClass.compact => _CompactShell(
        navigationShell: navigationShell,
      ),
      WindowSizeClass.medium => _RailShell(
        navigationShell: navigationShell,
        extended: false,
      ),
      WindowSizeClass.expanded => _RailShell(
        navigationShell: navigationShell,
        extended: true,
      ),
    };
  }
}

class _CompactShell extends StatelessWidget {
  const _CompactShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KgweboColors.canvas,
      body: navigationShell,
      bottomNavigationBar: CompactNavigation(navigationShell: navigationShell),
    );
  }
}

class _RailShell extends StatelessWidget {
  const _RailShell({required this.navigationShell, required this.extended});

  final StatefulNavigationShell navigationShell;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KgweboColors.canvas,
      body: SafeArea(
        child: Row(
          children: [
            RailNavigation(
              navigationShell: navigationShell,
              extended: extended,
            ),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      ),
    );
  }
}
