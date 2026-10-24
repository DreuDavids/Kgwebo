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
      headline: 'Reports are coming',
      message:
          'They will use the same figures as Home. Nothing is generated in this build.',
      actionLabel: 'Back to Home',
      onAction: () => context.goNamed(AppRoutes.dashboardName),
    );
  }
}
