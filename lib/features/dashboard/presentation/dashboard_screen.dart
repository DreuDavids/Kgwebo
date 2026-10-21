import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/config/app_environment.dart';
import '../../../app/config/config_providers.dart';
import '../../../app/theme/kgwebo_spacing.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../shared/widgets/kgwebo_status_banner.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_metrics.dart';
import 'widgets/dashboard_outlook.dart';
import 'widgets/dashboard_quick_actions.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: KgweboContentConstraint(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              0,
              KgweboSpacing.lg,
              0,
              KgweboSpacing.xl + bottomInset,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const KgweboPagePadding(child: DashboardHeader()),
                const SizedBox(height: KgweboSpacing.lg),
                const KgweboPagePadding(
                  child: KgweboStatusBanner(
                    tone: KgweboBannerTone.preview,
                    message:
                        'This home screen is a design foundation. Metric '
                        'tiles are labelled previews, not your business data.',
                  ),
                ),
                if (config.runtimeMode == AppRuntimeMode.local) ...[
                  const SizedBox(height: KgweboSpacing.sm),
                  KgweboPagePadding(
                    child: KgweboStatusBanner(
                      tone: KgweboBannerTone.warning,
                      message:
                          config.issues.isEmpty
                              ? 'Running in local preview. Backend credentials are not complete.'
                              : config.issues.first,
                    ),
                  ),
                ],
                if (config.runtimeMode == AppRuntimeMode.demo) ...[
                  const SizedBox(height: KgweboSpacing.sm),
                  const KgweboPagePadding(
                    child: KgweboStatusBanner(
                      tone: KgweboBannerTone.info,
                      message:
                          'Demo mode is on. Figures in later phases will be labelled sample data.',
                    ),
                  ),
                ],
                const SizedBox(height: KgweboSpacing.xl),
                const KgweboPagePadding(child: DashboardMetrics()),
                const SizedBox(height: KgweboSpacing.xl),
                const KgweboPagePadding(child: DashboardQuickActions()),
                const SizedBox(height: KgweboSpacing.xl),
                const KgweboPagePadding(child: DashboardOutlook()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
