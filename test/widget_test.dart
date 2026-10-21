import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/features/dashboard/presentation/dashboard_screen.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets('Kgwebo app shell launches on the dashboard', (tester) async {
    await pumpKgweboApp(tester);
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Kgwebo'), findsWidgets);
  });
}
