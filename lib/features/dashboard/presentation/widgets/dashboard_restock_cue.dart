import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/kgwebo_colors.dart';
import '../../../../app/theme/kgwebo_spacing.dart';
import '../../../../core/finance/recommendation_rules.dart';
import '../../../../shared/widgets/kgwebo_soft_card.dart';
import '../../../authentication/application/session_controller.dart';
import '../../../authentication/domain/app_session.dart';
import '../../../products/application/products_controller.dart';
import '../../../recommendations/application/recommendations_controller.dart';

class DashboardRestockCue extends ConsumerWidget {
  const DashboardRestockCue({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider);
    if (session is! AppSessionReady) {
      return const SizedBox.shrink();
    }

    final restockCount =
        ref
            .watch(inventoryAttentionProvider)
            .valueOrNull
            ?.restockProductIds
            .length ??
        0;
    if (restockCount <= 0) {
      return const SizedBox.shrink();
    }

    final recommendations = ref.watch(recommendationsControllerProvider);
    if (recommendations.items.any(
      (item) => item.ruleKey == RecommendationRuleKey.lowStock,
    )) {
      return const SizedBox.shrink();
    }

    final textTheme = Theme.of(context).textTheme;
    final title =
        restockCount == 1
            ? '1 product needs restocking'
            : '$restockCount products need restocking';
    return Padding(
      padding: const EdgeInsets.only(bottom: KgweboSpacing.lg),
      child: KgweboSoftCard(
        semanticLabel:
            '$title. Open Stock to review. Inventory value is not cash.',
        onTap: () {
          if (GoRouter.maybeOf(context) == null) {
            return;
          }
          context.goNamed(AppRoutes.productsName);
        },
        padding: const EdgeInsets.all(KgweboSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stock',
                    style: textTheme.labelLarge?.copyWith(
                      color: KgweboColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: KgweboSpacing.xxs),
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      color: KgweboColors.ink,
                    ),
                  ),
                  const SizedBox(height: KgweboSpacing.xxs),
                  Text(
                    'Open Stock to review. Inventory value is not cash.',
                    style: textTheme.bodySmall?.copyWith(
                      color: KgweboColors.inkMuted,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: KgweboSpacing.sm),
            const Icon(Icons.chevron_right, color: KgweboColors.inkMuted),
          ],
        ),
      ),
    );
  }
}
