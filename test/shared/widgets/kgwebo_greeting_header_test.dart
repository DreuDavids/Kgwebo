import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/app/theme/kgwebo_theme.dart';
import 'package:kgwebo/shared/widgets/kgwebo_greeting_header.dart';

void main() {
  testWidgets('puts hello and the business name on one line', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: KgweboTheme.light(),
        home: const Scaffold(
          body: KgweboGreetingHeader(businessName: 'Kgale stall'),
        ),
      ),
    );

    final headlines =
        tester
            .widgetList<RichText>(
              find.descendant(
                of: find.byType(KgweboGreetingHeader),
                matching: find.byType(RichText),
              ),
            )
            .map((widget) => widget.text.toPlainText())
            .toList();

    expect(headlines, contains('Hello, Kgale stall'));
    expect(find.text(KgweboGreetingHeader.tagline), findsOneWidget);
    expect(find.text('Good morning'), findsNothing);
    expect(find.text('Good afternoon'), findsNothing);
    expect(find.text('Good evening'), findsNothing);
  });
}
