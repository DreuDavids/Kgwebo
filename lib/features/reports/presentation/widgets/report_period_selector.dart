import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/kgwebo_colors.dart';
import '../../../../app/theme/kgwebo_spacing.dart';
import '../../../../core/finance/dashboard_period.dart';
import '../../../../shared/widgets/kgwebo_section_heading.dart';
import '../../application/report_controller.dart';

class ReportPeriodSelector extends ConsumerWidget {
  const ReportPeriodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportControllerProvider);
    final label = state.periodLabel.isEmpty ? 'This month' : state.periodLabel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KgweboSectionHeading(
          title: 'Reporting period',
          subtitle: 'This summary uses $label in the business calendar.',
        ),
        const SizedBox(height: KgweboSpacing.sm),
        SingleChildScrollView(
          key: const ValueKey('report-period-carousel'),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final kind in DashboardPeriodKind.values) ...[
                _PeriodChip(
                  label: _chipLabel(kind),
                  selected: state.periodKind == kind && !state.isPreview,
                  enabled: !state.isPreview,
                  onTap: () => _select(context, ref, kind),
                ),
                if (kind != DashboardPeriodKind.values.last)
                  const SizedBox(width: KgweboSpacing.xs),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _chipLabel(DashboardPeriodKind kind) {
    return switch (kind) {
      DashboardPeriodKind.thisMonth => 'This month',
      DashboardPeriodKind.lastMonth => 'Last month',
      DashboardPeriodKind.lastThreeMonths => 'Last 3 months',
      DashboardPeriodKind.thisYear => 'This year',
      DashboardPeriodKind.custom => 'Custom',
    };
  }

  Future<void> _select(
    BuildContext context,
    WidgetRef ref,
    DashboardPeriodKind kind,
  ) async {
    final controller = ref.read(reportControllerProvider.notifier);
    if (kind != DashboardPeriodKind.custom) {
      controller.selectPeriod(kind);
      return;
    }
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: DateTime(now.year, now.month, now.day),
      ),
      helpText: 'Choose a reporting range',
    );
    if (picked == null) {
      return;
    }
    if (picked.end.isBefore(picked.start)) {
      return;
    }
    controller.selectPeriod(
      DashboardPeriodKind.custom,
      customStart: DateTime(
        picked.start.year,
        picked.start.month,
        picked.start.day,
      ),
      customEnd: DateTime(picked.end.year, picked.end.month, picked.end.day),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: label,
      child: Material(
        color: selected ? KgweboColors.ink : KgweboColors.surface,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? KgweboColors.ink : KgweboColors.line,
          ),
        ),
        child: InkWell(
          onTap: enabled ? onTap : null,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: KgweboSpacing.md,
              vertical: KgweboSpacing.sm,
            ),
            child: Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: selected ? KgweboColors.onInk : KgweboColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
