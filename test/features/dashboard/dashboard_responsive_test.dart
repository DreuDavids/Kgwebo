import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/app/routes.dart';
import 'package:kgwebo/features/dashboard/presentation/dashboard_screen.dart';
import 'package:kgwebo/features/shell/compact_navigation.dart';
import 'package:kgwebo/features/shell/rail_navigation.dart';

import '../../helpers/pump_app.dart';

void main() {
  const profiles = <(String, Size)>[
    ('compact phone portrait', Size(320, 568)),
    ('standard phone portrait', Size(360, 800)),
    ('phone landscape', Size(800, 360)),
    ('tablet portrait', Size(768, 1024)),
    ('tablet landscape', Size(1024, 768)),
  ];

  for (final profile in profiles) {
    testWidgets('dashboard and navigation layout at ${profile.$1}', (
      tester,
    ) async {
      final overflows = <String>[];
      final original = FlutterError.onError;
      FlutterError.onError = (details) {
        final text = details.exceptionAsString();
        if (text.contains('overflowed')) {
          overflows.add(text);
        }
        original?.call(details);
      };
      addTearDown(() => FlutterError.onError = original);

      await pumpKgweboApp(tester, size: profile.$2);

      expect(tester.takeException(), isNull);
      expect(overflows, isEmpty, reason: overflows.join('\n'));
      expect(find.byType(ErrorWidget), findsNothing);
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.text('Record a sale'), findsOneWidget);

      final width = profile.$2.width;
      if (width < 600) {
        expect(find.byType(CompactNavigation), findsOneWidget);
        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.byType(RailNavigation), findsNothing);
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('More'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Cash Flow'),
          ),
          findsNothing,
        );
      } else {
        expect(find.byType(RailNavigation), findsOneWidget);
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);
        expect(find.text('Dashboard'), findsWidgets);
        expect(find.text('Cash Flow'), findsWidgets);
        expect(find.text('Settings'), findsWidgets);
      }
    });
  }

  testWidgets('compact More opens secondary destinations', (tester) async {
    await pumpKgweboApp(tester, size: const Size(360, 800));

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(find.text('Further destinations'), findsOneWidget);

    await tester.tap(find.text('Cash Flow'));
    await tester.pumpAndSettle();
    expect(find.text('Forecasts will be explainable'), findsOneWidget);
  });

  testWidgets('primary actions stay reachable on the smallest profile', (
    tester,
  ) async {
    await pumpKgweboApp(tester, size: const Size(320, 568));

    await tester.ensureVisible(find.text('Record a sale'));
    expect(find.text('Record a sale'), findsOneWidget);
    expect(find.text('Record an expense'), findsOneWidget);
    expect(find.text('Add a product'), findsOneWidget);
    expect(find.text('View cash flow'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('navigation and entered text survive a resize', (tester) async {
    final router = await pumpKgweboApp(tester, size: const Size(360, 800));

    router.go(AppRoutes.transactions);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'pending transport cost');
    expect(find.text('pending transport cost'), findsOneWidget);

    await setSurface(tester, const Size(1024, 768));
    await tester.pumpAndSettle();

    expect(find.text('Transactions'), findsWidgets);
    expect(find.text('pending transport cost'), findsOneWidget);
    expect(find.byType(NavigationRail), findsOneWidget);
  });
}
