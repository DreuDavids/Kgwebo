import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/app/theme/kgwebo_theme.dart';
import 'package:kgwebo/shared/widgets/kgwebo_greeting_header.dart';

void main() {
  testWidgets('shows a Gaborone morning greeting', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: KgweboTheme.light(),
        home: Scaffold(
          body: KgweboGreetingHeader(
            now: DateTime.utc(2026, 10, 21, 6),
            businessName: 'Kgale stall',
          ),
        ),
      ),
    );

    expect(find.text('Hello,'), findsOneWidget);
    expect(find.text('Good morning'), findsOneWidget);
    expect(find.text('Kgale stall'), findsOneWidget);
    expect(
      find.text('Totals come from saved records, not estimates.'),
      findsOneWidget,
    );
    expect(find.text(KgweboGreetingHeader.tagline), findsOneWidget);
  });

  test('greetingFor follows Gaborone wall time', () {
    expect(
      KgweboGreetingHeader.greetingFor(DateTime.utc(2026, 10, 21, 6)),
      'Good morning',
    );
    expect(
      KgweboGreetingHeader.greetingFor(DateTime.utc(2026, 10, 21, 12)),
      'Good afternoon',
    );
    expect(
      KgweboGreetingHeader.greetingFor(DateTime.utc(2026, 10, 21, 16)),
      'Good evening',
    );
  });
}
