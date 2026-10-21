import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/kgwebo_empty_state.dart';
import '../routes.dart';

class UnknownRouteScreen extends StatelessWidget {
  const UnknownRouteScreen({super.key, required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: SafeArea(
        child: KgweboEmptyState(
          icon: Icons.map_outlined,
          title: 'This page is not in Kgwebo',
          message: 'There is no screen for $location.',
          actionLabel: 'Go to dashboard',
          onAction: () => context.goNamed(AppRoutes.dashboardName),
        ),
      ),
    );
  }
}
