import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/config/app_environment.dart';
import '../../../../app/config/config_providers.dart';
import '../../../../app/theme/kgwebo_spacing.dart';
import '../../../../shared/widgets/kgwebo_status_banner.dart';
import '../../../authentication/application/session_controller.dart';
import '../../../authentication/domain/app_session.dart';
import '../../../products/application/products_controller.dart';
import '../../application/dashboard_finance_controller.dart';

class DashboardNotices extends ConsumerWidget {
  const DashboardNotices({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final session = ref.watch(appSessionProvider);
    final finance = ref.watch(dashboardFinanceControllerProvider);
    final stockAttention = ref.watch(inventoryAttentionProvider).valueOrNull;
    final restockCount = stockAttention?.restockProductIds.length ?? 0;
    final banners = <Widget>[
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
      if (finance.hitRecordCap)
        const KgweboStatusBanner(
          tone: KgweboBannerTone.warning,
          message:
              'Totals use the most recent 5,000 confirmed transactions. Older rows are not included in this summary.',
        ),
      if (finance.summary != null && finance.summary!.skippedMixedCurrency > 0)
        KgweboStatusBanner(
          tone: KgweboBannerTone.warning,
          message:
              '${finance.summary!.skippedMixedCurrency} confirmed rows in another currency were excluded. These totals are not a mixed-currency conversion.',
        ),
      if (config.runtimeMode == AppRuntimeMode.local)
        KgweboStatusBanner(
          tone: KgweboBannerTone.warning,
          message:
              config.issues.isEmpty
                  ? 'Running in local preview. Backend credentials are not complete.'
                  : config.issues.first,
        ),
      if (config.runtimeMode == AppRuntimeMode.demo)
        const KgweboStatusBanner(
          tone: KgweboBannerTone.info,
          message:
              'Demo mode is on. These screens do not write to a live Kgwebo account.',
        ),
      if (session is AppSessionReady &&
          finance.summary != null &&
          finance.summary!.countedEntries == 0)
        const KgweboStatusBanner(
          tone: KgweboBannerTone.info,
          message:
              'No sales or expenses are recorded yet. Cash shown is your opening / starting cash, which is not revenue.',
        ),
      if (session is AppSessionReady && restockCount > 0)
        KgweboStatusBanner(
          tone: KgweboBannerTone.warning,
          message:
              '$restockCount product${restockCount == 1 ? '' : 's'} need restocking. Open Products to review stock. Inventory value is not cash.',
        ),
    ];

    if (banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KgweboSpacing.md,
        0,
        KgweboSpacing.md,
        KgweboSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < banners.length; index++) ...[
            if (index > 0) const SizedBox(height: KgweboSpacing.sm),
            banners[index],
          ],
        ],
      ),
    );
  }
}
