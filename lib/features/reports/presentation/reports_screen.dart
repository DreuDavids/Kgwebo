import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../shared/widgets/feature_placeholder_page.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FeaturePlaceholderPage(
      title: 'Reports',
      icon: Icons.description_outlined,
      headline: 'Reports will match the engine',
      message:
          'You will preview and export a business summary whose figures come from '
          'the same calculations as the dashboard. PDF export is a later phase. '
          'Nothing is generated in this build.',
      actionLabel: 'Back to dashboard',
      onAction: () => context.goNamed(AppRoutes.dashboardName),
    );
  }
}
