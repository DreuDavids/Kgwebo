import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../../app/theme/kgwebo_colors.dart';
import '../../../app/theme/kgwebo_radii.dart';
import '../../../app/theme/kgwebo_spacing.dart';
import '../../../core/money/minor_units.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../shared/widgets/kgwebo_button.dart';
import '../../../shared/widgets/kgwebo_empty_state.dart';
import '../../../shared/widgets/kgwebo_loading_state.dart';
import '../../../shared/widgets/kgwebo_status_banner.dart';
import '../../onboarding/domain/business_profile.dart';
import '../../onboarding/domain/onboarding_options.dart';
import '../application/business_profile_controller.dart';

class BusinessProfileScreen extends ConsumerWidget {
  const BusinessProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(businessProfileControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business profile'),
        actions: [
          if (state.hasBusiness)
            TextButton(
              onPressed:
                  state.saving
                      ? null
                      : () =>
                          context.pushNamed(AppRoutes.businessProfileEditName),
              child: const Text('Edit'),
            ),
        ],
      ),
      body: SafeArea(
        child: KgweboFilledBody(child: _ProfileBody(state: state)),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.state});

  final BusinessProfileViewState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isPreview) {
      return const KgweboEmptyState(
        icon: Icons.storefront_outlined,
        title: 'Preview has no live business',
        message:
            'Sign in with a real account to view and edit a saved business profile.',
      );
    }
    if (state.loading) {
      return const KgweboLoadingState(message: 'Loading your business');
    }
    final profile = state.profile;
    if (profile == null) {
      return KgweboEmptyState(
        icon: Icons.storefront_outlined,
        title: 'Business profile unavailable',
        message:
            state.error ??
            'No saved business was found. Retry if this looks wrong.',
        actionLabel: 'Retry',
        onAction:
            () =>
                ref.read(businessProfileControllerProvider.notifier).refresh(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        KgweboSpacing.md,
        KgweboSpacing.md,
        KgweboSpacing.md,
        KgweboSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.isStale) ...[
            KgweboStatusBanner(
              tone: KgweboBannerTone.warning,
              message:
                  state.error == null
                      ? 'Showing the last saved copy. Check your connection to refresh.'
                      : '${state.error} Showing the last saved copy.',
            ),
            const SizedBox(height: KgweboSpacing.md),
          ] else if (state.success != null) ...[
            KgweboStatusBanner(
              tone: KgweboBannerTone.success,
              message: state.success!,
            ),
            const SizedBox(height: KgweboSpacing.md),
          ] else if (state.error != null) ...[
            KgweboStatusBanner(
              tone: KgweboBannerTone.warning,
              message: state.error!,
            ),
            const SizedBox(height: KgweboSpacing.md),
          ],
          _ProfileCard(profile: profile),
          const SizedBox(height: KgweboSpacing.md),
          KgweboButton(
            label: 'Edit profile',
            expanded: true,
            onPressed:
                () => context.pushNamed(AppRoutes.businessProfileEditName),
          ),
          if (state.isStale || state.error != null) ...[
            const SizedBox(height: KgweboSpacing.sm),
            KgweboButton(
              label: 'Retry',
              expanded: true,
              variant: KgweboButtonVariant.secondary,
              isLoading: state.refreshing,
              onPressed:
                  state.refreshing
                      ? null
                      : () =>
                          ref
                              .read(businessProfileControllerProvider.notifier)
                              .refresh(),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});

  final BusinessProfile profile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final rows = [
      ('Business name', profile.name),
      ('Business type', profile.businessType),
      ('Country', OnboardingOptions.countryLabel(profile.countryCode)),
      ('Currency', OnboardingOptions.currencyLabel(profile.currencyCode)),
      (
        'Opening / starting cash',
        '${profile.currencyCode} ${MinorUnits.format(profile.openingBalanceMinor)}',
      ),
      (
        'Description',
        (profile.description == null || profile.description!.isEmpty)
            ? 'Not added'
            : profile.description!,
      ),
      (
        'Business start date',
        profile.startedOn == null
            ? 'Not added'
            : DateFormat.yMMMd().format(profile.startedOn!),
      ),
      (
        'Contact phone',
        (profile.contactPhone == null || profile.contactPhone!.isEmpty)
            ? 'Not added'
            : profile.contactPhone!,
      ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: KgweboColors.surface,
        borderRadius: KgweboRadii.borderMd,
        border: Border.all(color: KgweboColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(KgweboSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(profile.name, style: textTheme.headlineSmall),
            const SizedBox(height: KgweboSpacing.xxs),
            Text(
              'Opening cash is a starting position, not revenue.',
              style: textTheme.bodySmall?.copyWith(
                color: KgweboColors.inkMuted,
              ),
            ),
            const SizedBox(height: KgweboSpacing.md),
            for (final row in rows) ...[
              Text(
                row.$1,
                style: textTheme.labelMedium?.copyWith(
                  color: KgweboColors.inkMuted,
                ),
              ),
              const SizedBox(height: KgweboSpacing.xxs),
              Text(row.$2, style: textTheme.bodyLarge),
              const SizedBox(height: KgweboSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}
