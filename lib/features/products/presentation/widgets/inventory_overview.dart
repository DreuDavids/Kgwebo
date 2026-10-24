import 'package:flutter/material.dart';

import '../../../../app/theme/kgwebo_colors.dart';
import '../../../../app/theme/kgwebo_radii.dart';
import '../../../../app/theme/kgwebo_spacing.dart';
import '../../../../core/inventory/inventory_insights.dart';
import '../../../../core/money/money_formatter.dart';
import '../../../../shared/widgets/kgwebo_soft_card.dart';
import '../../domain/product_query.dart';

class InventoryOverview extends StatelessWidget {
  const InventoryOverview({
    super.key,
    required this.insights,
    required this.currencyCode,
    this.selectedFilter,
    this.onFilterSelected,
  });

  final InventoryInsights insights;
  final String currencyCode;
  final ProductListFilter? selectedFilter;
  final ValueChanged<ProductListFilter>? onFilterSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final value = MoneyFormatter.formatMinor(
      insights.estimatedValueMinor,
      currencyCode: currencyCode,
    );
    final caption =
        insights.missingCostCount > 0
            ? '${insights.missingCostCount} active product${insights.missingCostCount == 1 ? '' : 's'} excluded (no recorded cost). Not cash.'
            : 'Recorded cost × quantity. Not cash, sales, or profit.';

    return KgweboSoftCard(
      padding: const EdgeInsets.all(KgweboSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estimated inventory value',
            style: textTheme.labelLarge?.copyWith(color: KgweboColors.inkMuted),
          ),
          const SizedBox(height: KgweboSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: textTheme.headlineLarge?.copyWith(
                color: KgweboColors.ink,
                height: 1.15,
              ),
            ),
          ),
          const SizedBox(height: KgweboSpacing.xxs),
          Text(
            caption,
            style: textTheme.bodySmall?.copyWith(
              color: KgweboColors.inkMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: KgweboSpacing.md),
          const ColoredBox(
            color: KgweboColors.line,
            child: SizedBox(height: 1, width: double.infinity),
          ),
          const SizedBox(height: KgweboSpacing.md),
          Row(
            children: [
              Expanded(
                child: _StatusMetric(
                  label: 'Active',
                  value: insights.activeCount,
                  filter: ProductListFilter.active,
                  selected: selectedFilter == ProductListFilter.active,
                  onSelected: onFilterSelected,
                ),
              ),
              const SizedBox(width: KgweboSpacing.xs),
              Expanded(
                child: _StatusMetric(
                  label: 'Low stock',
                  value: insights.lowStockCount,
                  filter: ProductListFilter.lowStock,
                  selected: selectedFilter == ProductListFilter.lowStock,
                  onSelected: onFilterSelected,
                ),
              ),
              const SizedBox(width: KgweboSpacing.xs),
              Expanded(
                child: _StatusMetric(
                  label: 'Out of stock',
                  value: insights.outOfStockCount,
                  filter: ProductListFilter.outOfStock,
                  selected: selectedFilter == ProductListFilter.outOfStock,
                  onSelected: onFilterSelected,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusMetric extends StatelessWidget {
  const _StatusMetric({
    required this.label,
    required this.value,
    required this.filter,
    required this.selected,
    this.onSelected,
  });

  final String label;
  final int value;
  final ProductListFilter filter;
  final bool selected;
  final ValueChanged<ProductListFilter>? onSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tone = _tone(filter, value);
    final well = selected ? KgweboColors.limeSoft : KgweboColors.surfaceMuted;
    final content = Padding(
      padding: const EdgeInsets.symmetric(
        vertical: KgweboSpacing.sm,
        horizontal: KgweboSpacing.xxs,
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: textTheme.titleLarge?.copyWith(color: tone, height: 1.1),
          ),
          const SizedBox(height: KgweboSpacing.xxs),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(color: KgweboColors.inkMuted),
          ),
        ],
      ),
    );

    if (onSelected == null) {
      return Semantics(
        label: '$label $value',
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: well,
            borderRadius: KgweboRadii.borderSm,
          ),
          child: content,
        ),
      );
    }

    return Semantics(
      button: true,
      selected: selected,
      label: '$label $value',
      child: Material(
        color: well,
        borderRadius: KgweboRadii.borderSm,
        child: InkWell(
          onTap: () => onSelected!(filter),
          borderRadius: KgweboRadii.borderSm,
          child: content,
        ),
      ),
    );
  }

  Color _tone(ProductListFilter filter, int count) {
    if (count <= 0) {
      return KgweboColors.inkMuted;
    }
    return switch (filter) {
      ProductListFilter.active => KgweboColors.ink,
      ProductListFilter.lowStock => KgweboColors.warning,
      ProductListFilter.outOfStock => KgweboColors.danger,
      ProductListFilter.archived || ProductListFilter.all => KgweboColors.ink,
    };
  }
}
