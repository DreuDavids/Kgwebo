import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/kgwebo_colors.dart';
import '../../../app/theme/kgwebo_spacing.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../shared/widgets/kgwebo_empty_state.dart';
import '../../../shared/widgets/kgwebo_loading_state.dart';
import '../../../shared/widgets/kgwebo_section_heading.dart';
import '../../../shared/widgets/kgwebo_status_banner.dart';
import '../application/recommendations_controller.dart';
import 'widgets/recommendation_card.dart';

class RecommendationsScreen extends ConsumerWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recommendationsControllerProvider);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      appBar: AppBar(title: const Text('Recommendations')),
      body: SafeArea(
        child: KgweboFilledBody(
          child: RefreshIndicator(
            onRefresh:
                () =>
                    ref
                        .read(recommendationsControllerProvider.notifier)
                        .refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                KgweboSpacing.md,
                KgweboSpacing.md,
                KgweboSpacing.md,
                KgweboSpacing.xl + bottomInset,
              ),
              children: [
                const KgweboSectionHeading(
                  title: 'From your saved records',
                  subtitle:
                      'Kgwebo only shows a recommendation when the underlying condition is present. Dismissals stay after refresh.',
                ),
                const SizedBox(height: KgweboSpacing.sm),
                if (state.isPreview)
                  const KgweboStatusBanner(
                    tone: KgweboBannerTone.preview,
                    message:
                        'Preview cannot save recommendation status. Sign in to keep dismissals.',
                  )
                else if (state.failedRefresh && state.items.isEmpty)
                  KgweboStatusBanner(
                    tone: KgweboBannerTone.warning,
                    message:
                        'Recommendations could not be loaded. This is not an empty list.'
                        '${state.error == null ? '' : ' ${state.error}'}',
                  )
                else if (state.isStale)
                  KgweboStatusBanner(
                    tone: KgweboBannerTone.warning,
                    message:
                        state.error ??
                        'Showing saved recommendation status from this device.',
                  ),
                const SizedBox(height: KgweboSpacing.md),
                if (state.loading && state.items.isEmpty)
                  const KgweboLoadingState(message: 'Checking saved records')
                else if (state.failedRefresh && state.items.isEmpty)
                  const SizedBox.shrink()
                else if (state.items.isEmpty)
                  const KgweboEmptyState(
                    icon: Icons.task_alt_outlined,
                    title: 'No active recommendations',
                    message:
                        'When overdue bills, tight cash after known commitments, last month’s operating result, or stock gaps appear in your records, they will show here.',
                  )
                else
                  for (final item in state.items) ...[
                    RecommendationCard(
                      item: item,
                      onDismiss:
                          state.isPreview || item.persisted == null
                              ? null
                              : () => ref
                                  .read(
                                    recommendationsControllerProvider.notifier,
                                  )
                                  .dismiss(item),
                    ),
                    const SizedBox(height: KgweboSpacing.md),
                  ],
                Text(
                  'These notices are not professional accounting, tax or investment advice.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: KgweboColors.inkMuted,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
