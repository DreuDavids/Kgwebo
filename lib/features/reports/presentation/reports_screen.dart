import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/kgwebo_spacing.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../shared/widgets/kgwebo_button.dart';
import '../../../shared/widgets/kgwebo_empty_state.dart';
import '../../../shared/widgets/kgwebo_loading_state.dart';
import '../../../shared/widgets/kgwebo_status_banner.dart';
import '../application/report_controller.dart';
import 'widgets/report_period_selector.dart';
import 'widgets/report_preview.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: SafeArea(
        child: KgweboFilledBody(
          child: Column(
            children: [
              Expanded(child: _body(ref, state)),
              _exportBar(ref, state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(WidgetRef ref, ReportViewState state) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        KgweboSpacing.md,
        KgweboSpacing.md,
        KgweboSpacing.md,
        KgweboSpacing.sm,
      ),
      children: [
        const ReportPeriodSelector(),
        const SizedBox(height: KgweboSpacing.md),
        if (state.isPreview)
          const KgweboEmptyState(
            icon: Icons.description_outlined,
            title: 'No live report in preview',
            message:
                'Sign in to generate a cash-basis summary from confirmed records.',
          )
        else if (state.loading && state.document == null)
          const KgweboLoadingState(message: 'Loading report')
        else if (state.error != null && state.document == null)
          KgweboEmptyState(
            icon: Icons.cloud_off_outlined,
            title: 'Could not load the report',
            message: state.error!,
            actionLabel: 'Retry',
            onAction:
                () => ref.read(reportControllerProvider.notifier).refresh(),
          )
        else if (state.document == null)
          const KgweboEmptyState(
            icon: Icons.description_outlined,
            title: 'No report yet',
            message: 'Sign in and record confirmed sales or expenses first.',
          )
        else ...[
          if (state.isStale)
            const Padding(
              padding: EdgeInsets.only(bottom: KgweboSpacing.md),
              child: KgweboStatusBanner(
                tone: KgweboBannerTone.warning,
                message:
                    'Showing saved figures from this device. They may not include the latest server copy. Pending changes are not included.',
              ),
            )
          else if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: KgweboSpacing.md),
              child: KgweboStatusBanner(
                tone: KgweboBannerTone.warning,
                message: state.error!,
              ),
            ),
          if (state.document!.isEmptyPeriod)
            Padding(
              padding: const EdgeInsets.only(bottom: KgweboSpacing.md),
              child: KgweboEmptyState(
                icon: Icons.event_busy_outlined,
                title:
                    'No confirmed transactions in ${state.periodLabel.isEmpty ? 'this period' : state.periodLabel}',
                message:
                    'Opening cash is a starting balance, so it is not listed as a sale. You can still export a zeroed summary for this period.',
              ),
            ),
          ReportPreview(document: state.document!),
        ],
      ],
    );
  }

  Widget _exportBar(WidgetRef ref, ReportViewState state) {
    final exporting = state.exportStatus == ReportExportStatus.exporting;
    final canExport = state.document != null && !state.isPreview && !exporting;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KgweboSpacing.md,
        KgweboSpacing.sm,
        KgweboSpacing.md,
        KgweboSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.exportStatus == ReportExportStatus.success)
            const Padding(
              padding: EdgeInsets.only(bottom: KgweboSpacing.sm),
              child: KgweboStatusBanner(
                tone: KgweboBannerTone.success,
                message: 'PDF ready. Choose where to share or save it.',
              ),
            )
          else if (state.exportError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: KgweboSpacing.sm),
              child: KgweboStatusBanner(
                tone: KgweboBannerTone.warning,
                message: state.exportError!,
              ),
            ),
          KgweboButton(
            label: exporting ? 'Creating PDF' : 'Export PDF',
            icon: Icons.ios_share_outlined,
            expanded: true,
            isLoading: exporting,
            onPressed:
                canExport
                    ? () =>
                        ref.read(reportControllerProvider.notifier).exportPdf()
                    : null,
          ),
        ],
      ),
    );
  }
}
