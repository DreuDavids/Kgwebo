import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/config/app_environment.dart';
import '../../../app/config/config_providers.dart';
import '../../../app/theme/kgwebo_spacing.dart';
import '../../../shared/widgets/kgwebo_status_banner.dart';
import '../../../shared/widgets/kgwebo_wash_scaffold.dart';
import '../../authentication/application/session_controller.dart';
import '../../authentication/domain/app_session.dart';
import '../application/dashboard_finance_controller.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_hero.dart';
import 'widgets/dashboard_insights_list.dart';
import 'widgets/dashboard_metrics.dart';
import 'widgets/dashboard_outlook.dart';
import 'widgets/dashboard_period_selector.dart';
import 'widgets/dashboard_quick_actions.dart';
import 'widgets/dashboard_recent.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final session = ref.watch(appSessionProvider);
    final finance = ref.watch(dashboardFinanceControllerProvider);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return KgweboWashScaffold(
      safeBottom: false,
      header: const DashboardHeader(),
      body: RefreshIndicator(
        onRefresh:
            () =>
                ref.read(dashboardFinanceControllerProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            KgweboSpacing.md,
            KgweboSpacing.lg,
            KgweboSpacing.md,
            KgweboSpacing.xl + bottomInset,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (finance.isPreview)
                const KgweboStatusBanner(
                  tone: KgweboBannerTone.preview,
                  message:
                      'This is a labelled preview. Metric tiles are not your business data.',
                )
              else if (finance.isStale)
                KgweboStatusBanner(
                  tone: KgweboBannerTone.warning,
                  message:
                      finance.error ??
                      'Showing saved figures from this device. They may not include the latest changes.',
                )
              else if (finance.error != null && finance.summary != null)
                KgweboStatusBanner(
                  tone: KgweboBannerTone.warning,
                  message: finance.error!,
                ),
              if (finance.hitRecordCap) ...[
                const SizedBox(height: KgweboSpacing.sm),
                const KgweboStatusBanner(
                  tone: KgweboBannerTone.warning,
                  message:
                      'Totals use the most recent 5,000 confirmed transactions. Older rows are not included in this summary.',
                ),
              ],
              if (finance.summary != null &&
                  finance.summary!.skippedMixedCurrency > 0) ...[
                const SizedBox(height: KgweboSpacing.sm),
                KgweboStatusBanner(
                  tone: KgweboBannerTone.warning,
                  message:
                      '${finance.summary!.skippedMixedCurrency} confirmed rows in another currency were excluded. These totals are not a mixed-currency conversion.',
                ),
              ],
              if (config.runtimeMode == AppRuntimeMode.local) ...[
                const SizedBox(height: KgweboSpacing.sm),
                KgweboStatusBanner(
                  tone: KgweboBannerTone.warning,
                  message:
                      config.issues.isEmpty
                          ? 'Running in local preview. Backend credentials are not complete.'
                          : config.issues.first,
                ),
              ],
              if (config.runtimeMode == AppRuntimeMode.demo) ...[
                const SizedBox(height: KgweboSpacing.sm),
                const KgweboStatusBanner(
                  tone: KgweboBannerTone.info,
                  message:
                      'Demo mode is on. These screens do not write to a live Kgwebo account.',
                ),
              ],
              if (session is AppSessionReady &&
                  finance.summary != null &&
                  finance.summary!.countedEntries == 0) ...[
                const SizedBox(height: KgweboSpacing.sm),
                const KgweboStatusBanner(
                  tone: KgweboBannerTone.info,
                  message:
                      'No sales or expenses are recorded yet. Cash shown is your opening / starting cash, which is not revenue.',
                ),
              ],
              const SizedBox(height: KgweboSpacing.lg),
              const DashboardPeriodSelector(),
              const SizedBox(height: KgweboSpacing.lg),
              const DashboardHero(),
              const SizedBox(height: KgweboSpacing.lg),
              const DashboardMetrics(),
              const SizedBox(height: KgweboSpacing.lg),
              const DashboardInsightsList(),
              const SizedBox(height: KgweboSpacing.lg),
              const DashboardQuickActions(),
              const SizedBox(height: KgweboSpacing.lg),
              const DashboardRecent(),
              const SizedBox(height: KgweboSpacing.lg),
              const DashboardOutlook(),
            ],
          ),
        ),
      ),
    );
  }
}
