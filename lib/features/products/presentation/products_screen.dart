import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../shared/widgets/feature_placeholder_page.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FeaturePlaceholderPage(
      title: 'Products',
      icon: Icons.inventory_2_outlined,
      headline: 'Stock and prices come next',
      message:
          'Add products, costs, selling prices and stock levels here. Inventory '
          'movements will stay consistent with sales. This section is still being built.',
      actionLabel: 'Back to dashboard',
      onAction: () => context.goNamed(AppRoutes.dashboardName),
    );
  }
}
