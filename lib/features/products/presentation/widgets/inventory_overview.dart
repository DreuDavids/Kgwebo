import 'package:flutter/material.dart';

import '../../../../app/theme/kgwebo_colors.dart';
import '../../../../app/theme/kgwebo_spacing.dart';
import '../../../../core/inventory/inventory_insights.dart';
import '../../../../core/money/money_formatter.dart';
import '../../../../shared/widgets/kgwebo_soft_card.dart';

class InventoryOverview extends StatelessWidget {
  const InventoryOverview({
    super.key,
    required this.insights,
    required this.currencyCode,
  });

  final InventoryInsights insights;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final value = MoneyFormatter.formatMinor(
      insights.estimatedValueMinor,
      currencyCode: currencyCode,
    );
    return KgweboSoftCard(
      padding: const EdgeInsets.all(KgweboSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Stock overview', style: textTheme.titleSmall),
          const SizedBox(height: KgweboSpacing.xs),
          Wrap(
            spacing: KgweboSpacing.md,
            runSpacing: KgweboSpacing.xs,
            children: [
              _Metric(label: 'Active', value: '${insights.activeCount}'),
              _Metric(label: 'Low stock', value: '${insights.lowStockCount}'),
              _Metric(
                label: 'Out of stock',
                value: '${insights.outOfStockCount}',
              ),
            ],
          ),
          const SizedBox(height: KgweboSpacing.sm),
          Text('Estimated inventory value $value', style: textTheme.titleSmall),
          const SizedBox(height: 2),
          Text(
            insights.missingCostCount > 0
                ? '${insights.missingCostCount} active product${insights.missingCostCount == 1 ? '' : 's'} excluded (no recorded cost). Estimate, not cash.'
                : 'Recorded cost × quantity. Estimate, not cash, sales or profit.',
            style: textTheme.bodySmall?.copyWith(color: KgweboColors.inkMuted),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: KgweboColors.inkMuted),
        ),
        Text(value, style: textTheme.titleMedium),
      ],
    );
  }
}
