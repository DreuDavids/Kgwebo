import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/app/routes.dart';
import 'package:kgwebo/app/widgets/config_error_screen.dart';
import 'package:kgwebo/features/dashboard/presentation/dashboard_screen.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_config.dart';

void main() {
  testWidgets('initial route is the dashboard', (tester) async {
    await pumpKgweboApp(tester);
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Kgwebo'), findsWidgets);
    expect(
      find.text('Your business. Clearer decisions. Stronger growth.'),
      findsOneWidget,
    );
  });

  testWidgets('each named destination can be opened', (tester) async {
    final router = await pumpKgweboApp(tester, size: const Size(1024, 768));

    Future<void> open(String location, String heading) async {
      router.go(location);
      await tester.pumpAndSettle();
      expect(find.text(heading), findsWidgets);
    }

    await open(AppRoutes.dashboard, 'Kgwebo');
    await open(AppRoutes.transactions, 'Transactions');
    await open(AppRoutes.products, 'Products');
    await open(AppRoutes.cashFlow, 'Cash Flow');
    await open(AppRoutes.reports, 'Reports');
    await open(AppRoutes.settings, 'Settings');
    await open(AppRoutes.more, 'More');
  });

  testWidgets('unknown routes show a recovery screen', (tester) async {
    final router = await pumpKgweboApp(tester);
    router.go('/this-route-does-not-exist');
    await tester.pumpAndSettle();

    expect(find.text('This page is not in Kgwebo'), findsOneWidget);
    expect(find.text('Go to dashboard'), findsOneWidget);

    await tester.tap(find.text('Go to dashboard'));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  testWidgets('production misconfiguration shows a blocking error', (
    tester,
  ) async {
    await pumpKgweboApp(
      tester,
      config: testConfig(url: null, appEnv: 'production'),
    );

    expect(find.byType(ConfigErrorScreen), findsOneWidget);
    expect(find.text('Kgwebo cannot start'), findsOneWidget);
    expect(
      find.textContaining('Demo data was not substituted'),
      findsOneWidget,
    );
    expect(find.byType(DashboardScreen), findsNothing);
  });
}
