import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../shared/widgets/feature_placeholder_page.dart';

class CashFlowScreen extends StatelessWidget {
  const CashFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FeaturePlaceholderPage(
      title: 'Cash Flow',
      icon: Icons.waterfall_chart_outlined,
      headline: 'Forecasts will be explainable',
      message:
          'Kgwebo will project recorded cash against upcoming bills for 7, 14 or '
          '30 days and say which records drive a warning. No invented future sales. '
          'Forecasting arrives after transactions.',
      actionLabel: 'Back to dashboard',
      onAction: () => context.goNamed(AppRoutes.dashboardName),
    );
  }
}
