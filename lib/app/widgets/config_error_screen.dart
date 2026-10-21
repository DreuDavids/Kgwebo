import 'package:flutter/material.dart';

import '../../shared/widgets/kgwebo_empty_state.dart';
import '../config/app_config.dart';
import '../theme/kgwebo_spacing.dart';

/// Shown instead of the app shell when production/staging config is incomplete.
/// Does not fall back to demo data.
class ConfigErrorScreen extends StatelessWidget {
  const ConfigErrorScreen({super.key, required this.config});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    final details =
        config.issues.isEmpty
            ? 'Required backend configuration is missing.'
            : config.issues.join('\n\n');
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(KgweboSpacing.lg),
          child: KgweboEmptyState(
            icon: Icons.cloud_off_outlined,
            title: 'Kgwebo cannot start',
            message:
                'This ${config.environment.name} build needs valid Supabase '
                'client configuration. Demo data was not substituted.\n\n$details',
          ),
        ),
      ),
    );
  }
}
