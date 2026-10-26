import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/kgwebo_colors.dart';
import '../../../../app/theme/kgwebo_spacing.dart';
import '../../../../core/finance/dashboard_period.dart';
import '../../../../core/finance/ledger_entry.dart';
import '../../application/transactions_controller.dart';
import '../../domain/transaction_categories.dart';
import 'transaction_type_style.dart';

class TransactionFilters extends ConsumerWidget {
  const TransactionFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionsControllerProvider);
    final categories =
        state.type == null
            ? const <({String value, String label})>[]
            : [
              for (final category in TransactionCategories.forType(state.type!))
                (value: category.code, label: category.label),
            ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KgweboSpacing.md,
        KgweboSpacing.xs,
        KgweboSpacing.md,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _FilterMenu(
                  label: _typeLabel(state.type),
                  tooltip: 'Filter by type',
                  active: state.type != null,
                  options: [
                    (value: 'all', label: 'All types'),
                    for (final type in MoneyMovementType.values)
                      (
                        value: type.name,
                        label: TransactionTypeStyle.label(type),
                      ),
                  ],
                  onSelected:
                      (value) => ref
                          .read(transactionsControllerProvider.notifier)
                          .applyTypeFilter(_typeFrom(value)),
                ),
              ),
              const SizedBox(width: KgweboSpacing.xs),
              Expanded(
                child: _FilterMenu(
                  label: _periodLabel(state.periodKind),
                  tooltip: 'Filter by period',
                  active: state.periodKind != null,
                  options: [
                    (value: 'all', label: 'All time'),
                    for (final kind in DashboardPeriodKind.values)
                      (value: kind.name, label: _periodLabel(kind)),
                  ],
                  onSelected:
                      (value) => _selectPeriod(
                        context,
                        ref,
                        value == 'all'
                            ? null
                            : DashboardPeriodKind.values.byName(value),
                      ),
                ),
              ),
              const SizedBox(width: KgweboSpacing.xs),
              Expanded(
                child: _FilterMenu(
                  label: _categoryLabel(state),
                  tooltip: 'Filter by category',
                  enabled: state.type != null,
                  active: state.category != null,
                  options: [
                    (value: 'all', label: 'All categories'),
                    ...categories,
                  ],
                  onSelected:
                      (value) => ref
                          .read(transactionsControllerProvider.notifier)
                          .applyCategoryFilter(value == 'all' ? null : value),
                ),
              ),
            ],
          ),
          if (state.hasActiveFilters) ...[
            const SizedBox(height: KgweboSpacing.xs),
            _ClearFiltersButton(
              onTap:
                  () =>
                      ref
                          .read(transactionsControllerProvider.notifier)
                          .clearFilters(),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectPeriod(
    BuildContext context,
    WidgetRef ref,
    DashboardPeriodKind? kind,
  ) async {
    final controller = ref.read(transactionsControllerProvider.notifier);
    if (kind != DashboardPeriodKind.custom) {
      await controller.applyPeriodFilter(kind);
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
      helpText: 'Filter by date',
    );
    if (picked == null) {
      return;
    }
    await controller.applyPeriodFilter(
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

String _typeLabel(MoneyMovementType? type) {
  return type == null ? 'All types' : TransactionTypeStyle.label(type);
}

String _periodLabel(DashboardPeriodKind? kind) {
  return switch (kind) {
    null => 'All time',
    DashboardPeriodKind.thisMonth => 'This month',
    DashboardPeriodKind.lastMonth => 'Last month',
    DashboardPeriodKind.lastThreeMonths => 'Last 3 months',
    DashboardPeriodKind.thisYear => 'This year',
    DashboardPeriodKind.custom => 'Custom',
  };
}

String _categoryLabel(TransactionsViewState state) {
  final type = state.type;
  final category = state.category;
  if (type == null || category == null) {
    return 'All categories';
  }
  return TransactionCategories.labelFor(type, category);
}

MoneyMovementType? _typeFrom(String value) {
  if (value == 'all') {
    return null;
  }
  return MoneyMovementType.values.byName(value);
}

class _FilterMenu extends StatelessWidget {
  const _FilterMenu({
    required this.label,
    required this.tooltip,
    required this.options,
    required this.onSelected,
    this.enabled = true,
    this.active = false,
  });

  final String label;
  final String tooltip;
  final bool enabled;
  final bool active;
  final List<({String value, String label})> options;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      enabled: enabled,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      position: PopupMenuPosition.under,
      onSelected: onSelected,
      itemBuilder:
          (context) => [
            for (final option in options)
              PopupMenuItem(value: option.value, child: Text(option.label)),
          ],
      child: SizedBox(
        width: double.infinity,
        child: _FilterButton(label: label, active: active, enabled: enabled),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.active,
    required this.enabled,
  });

  final String label;
  final bool active;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final foreground =
        !enabled
            ? KgweboColors.inkFaint
            : active
            ? KgweboColors.onInk
            : KgweboColors.ink;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 40),
        child: Material(
          color:
              !enabled
                  ? KgweboColors.surfaceMuted
                  : active
                  ? KgweboColors.ink
                  : KgweboColors.surface,
          shape: StadiumBorder(
            side: BorderSide(
              color:
                  !enabled
                      ? KgweboColors.surfaceMuted
                      : active
                      ? KgweboColors.ink
                      : KgweboColors.line,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              KgweboSpacing.sm,
              KgweboSpacing.xs,
              KgweboSpacing.xs,
              KgweboSpacing.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: foreground),
                  ),
                ),
                Icon(Icons.expand_more, size: 18, color: foreground),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ClearFiltersButton extends StatelessWidget {
  const _ClearFiltersButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Clear',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: KgweboSpacing.xs,
              vertical: KgweboSpacing.xxs,
            ),
            child: Text(
              'Clear',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: KgweboColors.inkMuted),
            ),
          ),
        ),
      ),
    );
  }
}
