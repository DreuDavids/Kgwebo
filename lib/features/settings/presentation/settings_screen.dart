import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme/kgwebo_colors.dart';
import '../../../app/theme/kgwebo_spacing.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../shared/widgets/kgwebo_button.dart';
import '../../../shared/widgets/kgwebo_soft_card.dart';
import '../../authentication/application/session_controller.dart';
import '../../authentication/domain/app_session.dart';
import '../../authentication/domain/auth_failure.dart';
import '../../sync/application/sync_queue_controller.dart';
import '../application/privacy_copy.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const SafeArea(child: KgweboFilledBody(child: _SettingsBody())),
    );
  }
}

class _SettingsBody extends ConsumerWidget {
  const _SettingsBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        KgweboSpacing.md,
        KgweboSpacing.md,
        KgweboSpacing.md,
        KgweboSpacing.xl,
      ),
      children: [
        Text(
          'Kgwebo',
          style: textTheme.headlineSmall?.copyWith(color: KgweboColors.ink),
        ),
        const SizedBox(height: KgweboSpacing.xxs),
        Text(
          'Account, pending changes, and your business.',
          style: textTheme.bodyMedium?.copyWith(color: KgweboColors.inkMuted),
        ),
        const SizedBox(height: KgweboSpacing.lg),
        const _PendingChangesCard(),
        const SizedBox(height: KgweboSpacing.md),
        const _AccountCard(),
        const SizedBox(height: KgweboSpacing.md),
        const _PrivacyCard(),
        const SizedBox(height: KgweboSpacing.md),
        const _BusinessProfileCard(),
      ],
    );
  }
}

class _AccountCard extends ConsumerWidget {
  const _AccountCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider);
    final rows = switch (session) {
      AppSessionPreview() => [('Status', 'Not signed in')],
      AppSessionReady(:final user, :final business) => [
        ('Email', user.email ?? 'Unknown'),
        ('Business', business.name),
      ],
      AppSessionNeedsOnboarding(:final user) => [
        ('Email', user.email ?? 'Unknown'),
      ],
      AppSessionGuest() => [('Status', 'Signed out')],
      _ => [('Status', 'Working')],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InfoCard(title: 'Account', rows: rows),
        if (session is AppSessionReady ||
            session is AppSessionNeedsOnboarding ||
            session is AppSessionFailure) ...[
          const SizedBox(height: KgweboSpacing.sm),
          KgweboButton(
            label: 'Sign out',
            expanded: true,
            variant: KgweboButtonVariant.secondary,
            onPressed: () async {
              try {
                await ref.read(sessionControllerProvider.notifier).signOut();
              } on AuthFailure catch (error) {
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(error.message)));
              }
            },
          ),
        ],
      ],
    );
  }
}

class _PendingChangesCard extends ConsumerWidget {
  const _PendingChangesCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider);
    if (session is! AppSessionReady) {
      return const SizedBox.shrink();
    }
    final queue = ref.watch(syncQueueControllerProvider);
    final hasPending = queue.waitingCount > 0 || queue.actionRequiredCount > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InfoCard(
          title: 'Pending changes',
          rows: [('Status', hasPending ? 'Pending' : 'Nothing waiting')],
        ),
        if (hasPending) ...[
          const SizedBox(height: KgweboSpacing.sm),
          KgweboButton(
            label: 'Review pending changes',
            expanded: true,
            variant: KgweboButtonVariant.secondary,
            onPressed: () => context.pushNamed(AppRoutes.syncQueueName),
          ),
        ],
      ],
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return KgweboSoftCard(
      onTap: () => context.pushNamed(AppRoutes.privacyName),
      semanticLabel: '${PrivacyCopy.cardTitle}. ${PrivacyCopy.cardSubtitle}',
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PrivacyCopy.cardTitle,
                  style: textTheme.titleMedium?.copyWith(
                    color: KgweboColors.ink,
                  ),
                ),
                const SizedBox(height: KgweboSpacing.xxs),
                Text(
                  PrivacyCopy.cardSubtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: KgweboColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: KgweboColors.inkMuted),
        ],
      ),
    );
  }
}

class _BusinessProfileCard extends ConsumerWidget {
  const _BusinessProfileCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider);
    final textTheme = Theme.of(context).textTheme;
    return switch (session) {
      AppSessionReady(:final business, :final isStale) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InfoCard(
            title: 'Business profile',
            rows: [
              ('Name', business.name),
              ('Type', business.businessType),
              (
                'Status',
                isStale ? 'Showing last saved copy' : 'Saved to your account',
              ),
            ],
          ),
          const SizedBox(height: KgweboSpacing.sm),
          KgweboButton(
            label: 'View and edit profile',
            expanded: true,
            variant: KgweboButtonVariant.secondary,
            onPressed: () => context.pushNamed(AppRoutes.businessProfileName),
          ),
        ],
      ),
      AppSessionPreview() => _InfoCard(
        title: 'Business profile',
        rows: const [('Status', 'Sign in to see your business')],
      ),
      AppSessionLoading() ||
      AppSessionResolving() ||
      AppSessionGuest() ||
      AppSessionNeedsEmailConfirmation() ||
      AppSessionPasswordRecovery() ||
      AppSessionNeedsOnboarding() ||
      AppSessionFailure() => Text(
        'A saved business profile appears here after you sign in.',
        style: textTheme.bodySmall?.copyWith(color: KgweboColors.inkMuted),
      ),
    };
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.rows});

  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return KgweboSoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(color: KgweboColors.ink),
          ),
          const SizedBox(height: KgweboSpacing.sm),
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
    );
  }
}
