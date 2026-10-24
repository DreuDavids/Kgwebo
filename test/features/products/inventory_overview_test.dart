import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/app/theme/kgwebo_colors.dart';
import 'package:kgwebo/core/inventory/inventory_insights.dart';
import 'package:kgwebo/features/products/domain/product_query.dart';
import 'package:kgwebo/features/products/presentation/widgets/inventory_overview.dart';

import '../../helpers/pump_app.dart';

void main() {
  const insights = InventoryInsights(
    activeCount: 2,
    lowStockCount: 0,
    outOfStockCount: 1,
    missingCostCount: 0,
    estimatedValueMinor: 7200,
    restockProductIds: ['p-out'],
  );

  testWidgets('leads with estimated value and equal status counts', (
    tester,
  ) async {
    await pumpThemed(
      tester,
      child: const Scaffold(
        body: InventoryOverview(insights: insights, currencyCode: 'BWP'),
      ),
    );

    expect(find.text('Estimated inventory value'), findsOneWidget);
    expect(find.text('P 72.00'), findsOneWidget);
    expect(
      find.text('Recorded cost × quantity. Not cash, sales, or profit.'),
      findsOneWidget,
    );
    expect(find.text('Stock overview'), findsNothing);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Low stock'), findsOneWidget);
    expect(find.text('Out of stock'), findsOneWidget);
  });

  testWidgets('explains excluded products when cost is missing', (
    tester,
  ) async {
    await pumpThemed(
      tester,
      child: const Scaffold(
        body: InventoryOverview(
          insights: InventoryInsights(
            activeCount: 3,
            lowStockCount: 0,
            outOfStockCount: 0,
            missingCostCount: 2,
            estimatedValueMinor: 1500,
            restockProductIds: [],
            missingCostProductIds: ['a', 'b'],
          ),
          currencyCode: 'BWP',
        ),
      ),
    );

    expect(
      find.text('2 active products excluded (no recorded cost). Not cash.'),
      findsOneWidget,
    );
  });

  testWidgets('status tiles apply the matching stock filter', (tester) async {
    ProductListFilter? selected = ProductListFilter.active;

    await pumpThemed(
      tester,
      child: StatefulBuilder(
        builder: (context, setState) {
          return Scaffold(
            body: InventoryOverview(
              insights: insights,
              currencyCode: 'BWP',
              selectedFilter: selected,
              onFilterSelected: (filter) => setState(() => selected = filter),
            ),
          );
        },
      ),
    );

    await tester.tap(find.text('Out of stock'));
    await tester.pump();

    expect(selected, ProductListFilter.outOfStock);

    final outOfStockTile = tester.widget<Material>(
      find
          .ancestor(
            of: find.text('Out of stock'),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(outOfStockTile.color, KgweboColors.limeSoft);
  });
}
