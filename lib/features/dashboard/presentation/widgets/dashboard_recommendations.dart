import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/kgwebo_spacing.dart';
import '../../../../shared/widgets/kgwebo_button.dart';
import '../../../../shared/widgets/kgwebo_section_heading.dart';
import '../../../../shared/widgets/kgwebo_status_banner.dart';
import '../../../recommendations/application/recommendations_controller.dart';
import '../../../recommendations/presentation/widgets/recommendation_card.dart';

class DashboardRecommendations extends ConsumerWidget {
  const DashboardRecommendations({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recommendationsControllerProvider);
    if (state.isPreview) {
      return const SizedBox.shrink();
    }
    if (state.failedRefresh && state.items.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KgweboSectionHeading(
            title: 'Recommendations',
            subtitle: 'Saved notices from your records.',
          ),
          const SizedBox(height: KgweboSpacing.sm),
          KgweboStatusBanner(
            tone: KgweboBannerTone.warning,
            message:
                'Recommendations could not be loaded. This is not an empty list.'
                '${state.error == null ? '' : ' ${state.error}'}',
          ),
        ],
      );
    }
    if (state.items.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KgweboSectionHeading(
          title: 'Recommendations',
          subtitle:
              'Only shown when your records meet the condition. These are not professional advice.',
        ),
        const SizedBox(height: KgweboSpacing.sm),
        if (state.isStale)
          Padding(
            padding: const EdgeInsets.only(bottom: KgweboSpacing.sm),
            child: KgweboStatusBanner(
              tone: KgweboBannerTone.warning,
              message:
                  state.error ??
                  'Showing saved recommendation status from this device.',
            ),
          ),
        for (final item in state.dashboardItems) ...[
          RecommendationCard(
            item: item,
            compact: true,
            onDismiss:
                item.persisted == null
                    ? null
                    : () => ref
                        .read(recommendationsControllerProvider.notifier)
                        .dismiss(item),
          ),
          const SizedBox(height: KgweboSpacing.sm),
        ],
        KgweboButton(
          label: 'All recommendations',
          variant: KgweboButtonVariant.text,
          onPressed: () => context.pushNamed(AppRoutes.recommendationsName),
        ),
      ],
    );
  }
}
