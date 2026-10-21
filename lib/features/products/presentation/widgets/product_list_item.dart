import 'package:flutter/material.dart';

import '../../../../app/theme/kgwebo_colors.dart';
import '../../../../app/theme/kgwebo_elevation.dart';
import '../../../../app/theme/kgwebo_radii.dart';
import '../../../../app/theme/kgwebo_spacing.dart';
import '../../../../core/inventory/quantity_formatter.dart';
import '../../../../core/inventory/stock_status.dart';
import '../../../../core/inventory/unit_of_measure.dart';
import '../../../../core/money/money_formatter.dart';
import '../../domain/catalog_product.dart';

class ProductListItem extends StatelessWidget {
  const ProductListItem({
    super.key,
    required this.product,
    required this.currencyCode,
    this.onTap,
  });

  final CatalogProduct product;
  final String currencyCode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final stock = QuantityFormatter.formatWithUnit(
      product.stockQuantityMilli,
      product.unitOfMeasure.label,
    );
    final price = MoneyFormatter.formatMinor(
      product.sellingPriceMinor,
      currencyCode: currencyCode,
    );
    final status = _statusLabel(product.availability);
    return Semantics(
      button: onTap != null,
      label: '${product.name}. $stock remaining. $status. $price',
      child: Material(
        color: KgweboColors.surface,
        borderRadius: KgweboRadii.borderLg,
        child: InkWell(
          onTap: onTap,
          borderRadius: KgweboRadii.borderLg,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: KgweboColors.surface,
              borderRadius: KgweboRadii.borderLg,
              boxShadow: KgweboElevation.soft,
            ),
            child: Padding(
              padding: const EdgeInsets.all(KgweboSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          [
                            if (product.sku != null) product.sku!,
                            stock,
                            status,
                          ].join(' · '),
                          style: textTheme.bodySmall?.copyWith(
                            color: _statusColor(product.availability),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: KgweboSpacing.sm),
                  Text(price, style: textTheme.titleSmall),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _statusLabel(StockAvailability availability) {
    return switch (availability) {
      StockAvailability.inStock => 'In stock',
      StockAvailability.lowStock => 'Low stock',
      StockAvailability.outOfStock => 'Out of stock',
    };
  }

  Color _statusColor(StockAvailability availability) {
    return switch (availability) {
      StockAvailability.inStock => KgweboColors.inkMuted,
      StockAvailability.lowStock => KgweboColors.warning,
      StockAvailability.outOfStock => KgweboColors.danger,
    };
  }
}
