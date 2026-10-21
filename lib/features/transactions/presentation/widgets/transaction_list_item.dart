import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/kgwebo_colors.dart';
import '../../../../app/theme/kgwebo_elevation.dart';
import '../../../../app/theme/kgwebo_radii.dart';
import '../../../../app/theme/kgwebo_spacing.dart';
import '../../../../core/finance/business_calendar.dart';
import '../../../../core/money/money_formatter.dart';
import '../../domain/business_transaction.dart';
import '../../domain/transaction_categories.dart';
import 'transaction_type_style.dart';

class TransactionListItem extends StatelessWidget {
  const TransactionListItem({super.key, required this.transaction, this.onTap});

  final BusinessTransaction transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final type = transaction.type;
    final color = TransactionTypeStyle.color(type);
    final sign = TransactionTypeStyle.isInflow(type) ? '+' : '−';
    final wall = BusinessCalendar.gaboroneWallTime(transaction.occurredAt);
    final dateLabel = DateFormat.yMMMd().format(wall);
    final amount = MoneyFormatter.formatMinor(
      transaction.amountMinor,
      currencyCode: transaction.currencyCode,
    );
    final category = TransactionCategories.labelFor(type, transaction.category);
    final unpaid = transaction.paymentStatus.name == 'unpaid';

    return Semantics(
      button: onTap != null,
      label:
          '${TransactionTypeStyle.label(type)}. $category. $sign$amount. $dateLabel',
      child: Material(
        color: KgweboColors.surface,
        borderRadius: KgweboRadii.borderLg,
        elevation: 0,
        shadowColor: Colors.transparent,
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
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      TransactionTypeStyle.icon(type),
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: KgweboSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                          style: textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          [
                            TransactionTypeStyle.label(type),
                            dateLabel,
                            if (unpaid) 'Unpaid',
                          ].join(' · '),
                          style: textTheme.bodySmall?.copyWith(
                            color: KgweboColors.inkMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: KgweboSpacing.sm),
                  Text(
                    '$sign$amount',
                    style: textTheme.titleSmall?.copyWith(color: color),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
