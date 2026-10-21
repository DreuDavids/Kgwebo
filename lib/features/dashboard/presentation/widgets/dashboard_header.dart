import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/kgwebo_colors.dart';
import '../../../../app/theme/kgwebo_radii.dart';
import '../../../../app/theme/kgwebo_spacing.dart';
import '../../../../app/theme/kgwebo_typography.dart';
import '../../../authentication/application/session_controller.dart';
import '../../../authentication/domain/app_session.dart';

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final session = ref.watch(appSessionProvider);
    final businessName =
        session is AppSessionReady ? session.business.name : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: KgweboColors.forest,
                borderRadius: KgweboRadii.borderMd,
              ),
              alignment: Alignment.center,
              child: Text(
                'K',
                style: textTheme.titleLarge?.copyWith(
                  fontFamily: KgweboTypography.serif,
                  color: KgweboColors.onForest,
                ),
              ),
            ),
            const SizedBox(width: KgweboSpacing.sm),
            Expanded(
              child: Text(
                businessName ?? 'Kgwebo',
                style: textTheme.displayMedium?.copyWith(
                  color: KgweboColors.forest,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: KgweboSpacing.sm),
        Text(
          'Your business. Clearer decisions. Stronger growth.',
          style: textTheme.titleMedium?.copyWith(color: KgweboColors.inkMuted),
        ),
        const SizedBox(height: KgweboSpacing.md),
        Text(
          businessName == null
              ? 'A calm place to record sales, understand cash, and see what to do '
                  'next — built for traders and small retailers who do not have time '
                  'for accounting software.'
              : 'Home for $businessName. Totals still wait for recorded sales and expenses.',
          style: textTheme.bodyLarge?.copyWith(height: 1.5),
        ),
      ],
    );
  }
}
