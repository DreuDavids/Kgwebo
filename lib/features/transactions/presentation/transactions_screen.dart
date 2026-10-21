import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../shared/widgets/feature_placeholder_page.dart';
import '../../../shared/widgets/kgwebo_text_field.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FeaturePlaceholderPage(
      title: 'Transactions',
      icon: Icons.receipt_long_outlined,
      headline: 'Sales and expenses will live here',
      message:
          'You will record sales, expenses, refunds and owner movements in this '
          'section. Capture and totals are being built next — nothing is saved yet.',
      actionLabel: 'Back to dashboard',
      onAction: () => context.goNamed(AppRoutes.dashboardName),
      header: KgweboTextField(
        controller: _searchController,
        label: 'Search transactions',
        hint: 'Search will filter records once they exist',
        prefixIcon: Icons.search,
        textInputAction: TextInputAction.search,
        onChanged: (_) => setState(() {}),
      ),
    );
  }
}
