import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme/kgwebo_colors.dart';
import '../../../app/theme/kgwebo_spacing.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../shared/widgets/kgwebo_pill_row.dart';
import '../../../shared/widgets/kgwebo_soft_card.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: SafeArea(
        child: KgweboContentConstraint(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              KgweboSpacing.md,
              KgweboSpacing.md,
              KgweboSpacing.md,
              KgweboSpacing.xl,
            ),
            children: [
              Text(
                'Everything else',
                style: textTheme.titleMedium?.copyWith(color: KgweboColors.ink),
              ),
              const SizedBox(height: KgweboSpacing.xs),
              Text(
                'Bills, reports, your business, and account settings.',
                style: textTheme.bodyMedium?.copyWith(
                  color: KgweboColors.inkMuted,
                ),
              ),
              const SizedBox(height: KgweboSpacing.lg),
              KgweboSoftCard(
                padding: const EdgeInsets.symmetric(vertical: KgweboSpacing.xs),
                child: Column(
                  children: [
                    KgweboPillRow(
                      icon: Icons.event_outlined,
                      title: 'Bills',
                      subtitle: 'Money you still need to pay',
                      showChevron: true,
                      onTap: () => context.goNamed(AppRoutes.cashFlowName),
                    ),
                    KgweboPillRow(
                      icon: Icons.description_outlined,
                      title: 'Reports',
                      subtitle: 'A summary of the same figures as Home',
                      showChevron: true,
                      onTap: () => context.goNamed(AppRoutes.reportsName),
                    ),
                    KgweboPillRow(
                      icon: Icons.storefront_outlined,
                      title: 'Business',
                      subtitle: 'Your profile',
                      showChevron: true,
                      onTap:
                          () =>
                              context.pushNamed(AppRoutes.businessProfileName),
                    ),
                    KgweboPillRow(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      subtitle: 'Account',
                      showChevron: true,
                      onTap: () => context.goNamed(AppRoutes.settingsName),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
