import 'package:flutter/material.dart';

import '../../shared/widgets/kgwebo_empty_state.dart';
import '../theme/kgwebo_spacing.dart';

/// Shown instead of the app shell when production/staging config is incomplete.
/// Does not fall back to demo data.
class ConfigErrorScreen extends StatelessWidget {
  const ConfigErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(KgweboSpacing.lg),
          child: const KgweboEmptyState(
            icon: Icons.cloud_off_outlined,
            title: 'Kgwebo cannot start',
            message:
                'This copy of the app is not ready. Please update or reinstall.',
          ),
        ),
      ),
    );
  }
}
