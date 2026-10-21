import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/shared/widgets/kgwebo_button.dart';
import 'package:kgwebo/shared/widgets/kgwebo_empty_state.dart';
import 'package:kgwebo/shared/widgets/kgwebo_loading_state.dart';
import 'package:kgwebo/shared/widgets/kgwebo_section_heading.dart';
import 'package:kgwebo/shared/widgets/kgwebo_text_field.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('primary button invokes its callback', (tester) async {
    var tapped = false;
    await pumpThemed(
      tester,
      child: Scaffold(
        body: KgweboButton(label: 'Continue', onPressed: () => tapped = true),
      ),
    );

    await tester.tap(find.text('Continue'));
    expect(tapped, isTrue);
  });

  testWidgets('null onPressed disables the button', (tester) async {
    await pumpThemed(
      tester,
      child: const Scaffold(body: KgweboButton(label: 'Save', onPressed: null)),
    );

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('text field, heading, empty and loading states render', (
    tester,
  ) async {
    await pumpThemed(
      tester,
      child: const Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              KgweboSectionHeading(
                title: 'Recent activity',
                subtitle: 'Newest first',
              ),
              KgweboTextField(label: 'Amount'),
              KgweboEmptyState(
                icon: Icons.inbox_outlined,
                title: 'No transactions yet',
                message: 'Record a sale to see it here.',
              ),
              KgweboLoadingState(message: 'Loading records'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Recent activity'), findsOneWidget);
    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('No transactions yet'), findsOneWidget);
    expect(find.text('Loading records'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('icon button exposes an accessible name', (tester) async {
    await pumpThemed(
      tester,
      child: Scaffold(
        body: KgweboIconButton(
          icon: Icons.close,
          tooltip: 'Dismiss recommendation',
          onPressed: () {},
        ),
      ),
    );

    expect(find.byTooltip('Dismiss recommendation'), findsOneWidget);
  });
}
