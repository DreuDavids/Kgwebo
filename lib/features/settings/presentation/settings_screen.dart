import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/config/app_environment.dart';
import '../../../app/config/config_providers.dart';
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

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const SafeArea(
        child: KgweboContentConstraint(child: _SettingsBody()),
      ),
    );
  }
}

class _SettingsBody extends ConsumerWidget {
  const _SettingsBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
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
          'Account, session and environment. Working actions only.',
          style: textTheme.bodyMedium?.copyWith(color: KgweboColors.inkMuted),
        ),
        const SizedBox(height: KgweboSpacing.lg),
        const _AccountCard(),
        const SizedBox(height: KgweboSpacing.md),
        const _PendingChangesCard(),
        const SizedBox(height: KgweboSpacing.md),
        const _BusinessProfileCard(),
        const SizedBox(height: KgweboSpacing.md),
        _InfoCard(
          title: 'Runtime',
          rows: [
            ('Environment', config.environment.name),
            ('Mode', _modeLabel(config.runtimeMode)),
            (
              'Backend session',
              config.connectsToBackend
                  ? 'Supabase client initialised'
                  : 'Not opened',
            ),
          ],
        ),
        const SizedBox(height: KgweboSpacing.md),
        _InfoCard(
          title: 'Configuration',
          rows: [
            (
              'Supabase URL',
              config.supabaseUrl == null ? 'Missing' : 'Present',
            ),
            (
              'Publishable key',
              config.hasSupabaseAnonKey ? 'Present' : 'Missing',
            ),
            (
              'Ready for live backend',
              config.isBackendConfigured ? 'Yes' : 'No',
            ),
          ],
        ),
        if (config.issues.isNotEmpty) ...[
          const SizedBox(height: KgweboSpacing.md),
          _InfoCard(
            title: 'What to fix',
            rows: [for (final issue in config.issues) ('Issue', issue)],
          ),
        ],
      ],
    );
  }

  String _modeLabel(AppRuntimeMode mode) {
    return switch (mode) {
      AppRuntimeMode.live => 'Live credentials loaded',
      AppRuntimeMode.local => 'Local preview',
      AppRuntimeMode.demo => 'Explicit demo',
    };
  }
}

class _AccountCard extends ConsumerWidget {
  const _AccountCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider);
    final textTheme = Theme.of(context).textTheme;
    final rows = switch (session) {
      AppSessionPreview(:final mode) => [
        (
          'Status',
          mode == AppRuntimeMode.demo ? 'Explicit demo' : 'Local preview',
        ),
        ('Account', 'No real user session'),
      ],
      AppSessionReady(:final user, :final business) => [
        ('Status', 'Signed in'),
        ('Email', user.email ?? 'Unknown'),
        ('Business', business.name),
      ],
      AppSessionNeedsOnboarding(:final user) => [
        ('Status', 'Signed in, setup incomplete'),
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
        const SizedBox(height: KgweboSpacing.xs),
        Text(
          'Sign-out clears the Supabase session on this device. It does not '
          'delete your business records.',
          style: textTheme.bodySmall?.copyWith(color: KgweboColors.inkMuted),
        ),
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
    final waiting = queue.waitingCount;
    final blocked = queue.actionRequiredCount;
    final status =
        blocked > 0
            ? '$blocked need review'
            : waiting > 0
            ? '$waiting waiting to sync'
            : 'Nothing waiting';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InfoCard(
          title: 'Pending changes',
          rows: [
            ('Status', status),
            (
              'What this means',
              'Queued sales and commitments stay on this device until the server accepts them. They are not confirmed cash.',
            ),
          ],
        ),
        const SizedBox(height: KgweboSpacing.sm),
        KgweboButton(
          label: 'Review pending changes',
          expanded: true,
          variant: KgweboButtonVariant.secondary,
          onPressed: () => context.pushNamed(AppRoutes.syncQueueName),
        ),
      ],
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
        rows: const [('Status', 'Preview mode does not load a live business')],
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
