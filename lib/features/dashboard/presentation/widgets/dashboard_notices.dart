import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/config/app_environment.dart';
import '../../../../app/config/config_providers.dart';
import '../../../../app/theme/kgwebo_spacing.dart';
import '../../../../shared/widgets/kgwebo_status_banner.dart';
import '../../../sync/application/sync_queue_controller.dart';
import '../../../sync/presentation/sync_notice.dart';
import '../../application/dashboard_finance_controller.dart';

class DashboardNotices extends ConsumerWidget {
  const DashboardNotices({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final finance = ref.watch(dashboardFinanceControllerProvider);
    final queue = ref.watch(syncQueueControllerProvider);
    final banners = <Widget>[
      if (queue.hasOpen) const KgweboSyncNotice(),
      if (finance.isPreview)
        const KgweboStatusBanner(
          tone: KgweboBannerTone.preview,
          message: 'These figures are examples, not your business.',
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
      if (config.runtimeMode == AppRuntimeMode.demo)
        const KgweboStatusBanner(
          tone: KgweboBannerTone.info,
          message: 'This is a demo. Figures here are examples.',
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
