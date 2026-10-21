import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/kgwebo_colors.dart';
import '../../../app/theme/kgwebo_radii.dart';
import '../../../app/theme/kgwebo_spacing.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../shell/app_destinations.dart';

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
              Text('Further destinations', style: textTheme.titleMedium),
              const SizedBox(height: KgweboSpacing.xs),
              Text(
                'Cash flow, reports and settings stay one tap away on small screens '
                'so the bottom bar remains usable.',
                style: textTheme.bodyMedium?.copyWith(
                  color: KgweboColors.inkMuted,
                ),
              ),
              const SizedBox(height: KgweboSpacing.lg),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: KgweboColors.surface,
                  borderRadius: KgweboRadii.borderMd,
                  border: Border.all(color: KgweboColors.line),
                ),
                child: Column(
                  children: [
                    for (final destination in AppDestinationX.moreDestinations)
                      ListTile(
                        leading: Icon(
                          destination.icon,
                          color: KgweboColors.forest,
                        ),
                        title: Text(destination.label),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.goNamed(destination.routeName),
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
