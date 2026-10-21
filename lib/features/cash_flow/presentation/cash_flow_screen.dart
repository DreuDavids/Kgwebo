import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../../app/theme/kgwebo_colors.dart';
import '../../../app/theme/kgwebo_spacing.dart';
import '../../../core/finance/business_calendar.dart';
import '../../../core/money/money_formatter.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../shared/widgets/kgwebo_button.dart';
import '../../../shared/widgets/kgwebo_empty_state.dart';
import '../../../shared/widgets/kgwebo_loading_state.dart';
import '../../../shared/widgets/kgwebo_pill_row.dart';
import '../../../shared/widgets/kgwebo_section_heading.dart';
import '../../../shared/widgets/kgwebo_soft_card.dart';
import '../../../shared/widgets/kgwebo_status_banner.dart';
import '../../authentication/application/session_controller.dart';
import '../../authentication/domain/app_session.dart';
import '../../dashboard/application/dashboard_finance_controller.dart';
import '../../dashboard/presentation/widgets/cash_forecast_card.dart';
import '../../dashboard/presentation/widgets/forecast_horizon_chips.dart';
import '../../../core/sync/outbox_models.dart';
import '../../obligations/application/obligations_controller.dart';
import '../../obligations/domain/business_obligation.dart';
import '../../obligations/domain/obligation_categories.dart';
import '../../sync/application/sync_queue_controller.dart';
import '../../sync/presentation/sync_notice.dart';

class CashFlowScreen extends ConsumerWidget {
  const CashFlowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider);
    final finance = ref.watch(dashboardFinanceControllerProvider);
    final obligations = ref.watch(obligationsControllerProvider);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final zone =
        session is AppSessionReady
            ? BusinessZone.forCountry(session.business.countryCode)
            : BusinessZone.africaGaborone;
    final now = DateTime.now().toUtc();

    return Scaffold(
      appBar: AppBar(title: const Text('Cash Flow')),
      body: SafeArea(
        child: KgweboFilledBody(
          child: RefreshIndicator(
            onRefresh: () async {
              await ref.read(obligationsControllerProvider.notifier).refresh();
              await ref
                  .read(dashboardFinanceControllerProvider.notifier)
                  .refresh();
            },
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
                  title: 'Commitments and recorded cash',
                  subtitle:
                      'Unpaid bills are not expenses and do not reduce current cash until you record a paid expense.',
                ),
                const SizedBox(height: KgweboSpacing.sm),
                const KgweboSyncNotice(),
                if (obligations.isPreview)
                  const KgweboStatusBanner(
                    tone: KgweboBannerTone.preview,
                    message:
                        'Preview cannot save commitments. Sign in to record upcoming bills.',
                  )
                else if (obligations.isStale)
                  KgweboStatusBanner(
                    tone: KgweboBannerTone.warning,
                    message:
                        obligations.error ??
                        'Showing saved commitments from this device.',
                  ),
                const SizedBox(height: KgweboSpacing.md),
                if (!obligations.isPreview && finance.forecast != null) ...[
                  ForecastHorizonChips(
                    selected: finance.forecastHorizon,
                    onSelected:
                        (horizon) => ref
                            .read(dashboardFinanceControllerProvider.notifier)
                            .selectHorizon(horizon),
                  ),
                  const SizedBox(height: KgweboSpacing.md),
                ],
                _EstimateCard(finance: finance),
                const SizedBox(height: KgweboSpacing.lg),
                KgweboButton(
                  label: 'Add a commitment',
                  expanded: true,
                  onPressed:
                      obligations.isPreview
                          ? null
                          : () =>
                              context.pushNamed(AppRoutes.recordObligationName),
                ),
                const SizedBox(height: KgweboSpacing.lg),
                if (obligations.loading && obligations.items.isEmpty)
                  const KgweboLoadingState(message: 'Loading commitments')
                else if (obligations.items.isEmpty)
                  KgweboEmptyState(
                    icon: Icons.event_outlined,
                    title: 'No commitments yet',
                    message:
                        'Record rent, supplier payments or loan repayments. Kgwebo will not invent upcoming bills.',
                    actionLabel:
                        obligations.isPreview ? null : 'Add a commitment',
                    onAction:
                        obligations.isPreview
                            ? null
                            : () => context.pushNamed(
                              AppRoutes.recordObligationName,
                            ),
                  )
                else
                  ..._grouped(context, ref, obligations.items, now, zone),
                const SizedBox(height: KgweboSpacing.lg),
                Text(
                  'This outlook does not invent future sales and is not professional accounting, tax or investment advice.',
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

  List<Widget> _grouped(
    BuildContext context,
    WidgetRef ref,
    List<BusinessObligation> items,
    DateTime asOf,
    BusinessZone zone,
  ) {
    final overdue = <BusinessObligation>[];
    final unpaid = <BusinessObligation>[];
    final settled = <BusinessObligation>[];
    for (final item in items) {
      switch (item.displayStatus(asOf: asOf, zone: zone)) {
        case ObligationDisplayStatus.overdue:
          overdue.add(item);
        case ObligationDisplayStatus.unpaid:
          unpaid.add(item);
        case ObligationDisplayStatus.paid:
        case ObligationDisplayStatus.cancelled:
          settled.add(item);
      }
    }
    return [
      if (overdue.isNotEmpty) ...[
        const KgweboSectionHeading(
          title: 'Overdue',
          subtitle: 'Still unpaid after the due date.',
        ),
        const SizedBox(height: KgweboSpacing.sm),
        _ObligationGroup(items: overdue, asOf: asOf, zone: zone, ref: ref),
        const SizedBox(height: KgweboSpacing.lg),
      ],
      if (unpaid.isNotEmpty) ...[
        const KgweboSectionHeading(
          title: 'Upcoming',
          subtitle: 'Saved commitments that have not been paid.',
        ),
        const SizedBox(height: KgweboSpacing.sm),
        _ObligationGroup(items: unpaid, asOf: asOf, zone: zone, ref: ref),
        const SizedBox(height: KgweboSpacing.lg),
      ],
      if (settled.isNotEmpty) ...[
        const KgweboSectionHeading(
          title: 'Paid or cancelled',
          subtitle: 'These no longer affect the cash estimate.',
        ),
        const SizedBox(height: KgweboSpacing.sm),
        _ObligationGroup(items: settled, asOf: asOf, zone: zone, ref: ref),
      ],
    ];
  }
}

class _EstimateCard extends StatelessWidget {
  const _EstimateCard({required this.finance});

  final DashboardFinanceState finance;

  @override
  Widget build(BuildContext context) {
    final forecast = finance.forecast;
    if (forecast != null) {
      return CashForecastCard(forecast: forecast);
    }
    final textTheme = Theme.of(context).textTheme;
    return KgweboSoftCard(
      padding: const EdgeInsets.all(KgweboSpacing.lg),
      child: Text(
        finance.isPreview
            ? 'Sign in to compare recorded cash with upcoming bills.'
            : finance.error != null
            ? 'Commitments could not be loaded. This is not a zero-bills result.'
            : 'Recorded cash will appear here after totals load.',
        style: textTheme.bodyMedium?.copyWith(color: KgweboColors.inkMuted),
      ),
    );
  }
}

class _ObligationGroup extends StatelessWidget {
  const _ObligationGroup({
    required this.items,
    required this.asOf,
    required this.zone,
    required this.ref,
  });

  final List<BusinessObligation> items;
  final DateTime asOf;
  final BusinessZone zone;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return KgweboSoftCard(
      padding: const EdgeInsets.symmetric(vertical: KgweboSpacing.xs),
      child: Column(
        children: [
          for (final item in items)
            KgweboPillRow(
              icon: Icons.event_outlined,
              title: item.title,
              subtitle:
                  '${ObligationCategories.labelFor(item.category)} · ${DateFormat.yMMMd().format(item.dueOn)} · ${_label(item)}${_pendingSuffix(item)}',
              trailingLabel: MoneyFormatter.formatMinor(
                item.amountMinor,
                currencyCode: item.currencyCode,
              ),
              trailingFilled:
                  item.displayStatus(asOf: asOf, zone: zone) ==
                  ObligationDisplayStatus.overdue,
              onTap:
                  () =>
                      item.pendingSync
                          ? context.pushNamed(AppRoutes.syncQueueName)
                          : context.pushNamed(
                            AppRoutes.obligationDetailsName,
                            pathParameters: {'obligationId': item.id},
                          ),
            ),
        ],
      ),
    );
  }

  String _label(BusinessObligation item) {
    return switch (item.displayStatus(asOf: asOf, zone: zone)) {
      ObligationDisplayStatus.overdue => 'Overdue',
      ObligationDisplayStatus.unpaid => 'Unpaid',
      ObligationDisplayStatus.paid => 'Paid',
      ObligationDisplayStatus.cancelled => 'Cancelled',
    };
  }

  String _pendingSuffix(BusinessObligation item) {
    if (!item.pendingSync) {
      return '';
    }
    final queue = ref.watch(syncQueueControllerProvider);
    for (final operation in queue.operations) {
      if (item.id == 'pending:${operation.operationId}') {
        return ' · ${operation.state.userLabel}';
      }
    }
    return ' · ${OutboxState.pending.userLabel}';
  }
}
