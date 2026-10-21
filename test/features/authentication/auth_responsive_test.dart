import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/app/routes.dart';
import 'package:kgwebo/features/authentication/domain/app_session.dart';
import 'package:kgwebo/features/authentication/domain/auth_user.dart';
import 'package:kgwebo/features/authentication/presentation/sign_in_screen.dart';
import 'package:kgwebo/features/authentication/presentation/welcome_screen.dart';
import 'package:kgwebo/features/onboarding/presentation/onboarding_screen.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_config.dart';

void main() {
  const profiles = <(String, Size)>[
    ('compact phone portrait', Size(320, 568)),
    ('standard phone portrait', Size(360, 800)),
    ('phone landscape', Size(800, 360)),
    ('tablet portrait', Size(768, 1024)),
    ('tablet landscape', Size(1024, 768)),
  ];

  for (final profile in profiles) {
    testWidgets('welcome remains usable at ${profile.$1}', (tester) async {
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

      await pumpKgweboApp(
        tester,
        size: profile.$2,
        config: testConfig(anonKey: 'sb_publishable_test'),
        session: const AppSessionGuest(),
        location: AppRoutes.welcome,
      );

      expect(tester.takeException(), isNull);
      expect(overflows, isEmpty, reason: overflows.join('\n'));
      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.text('I already have an account'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('sign-in remains scrollable at ${profile.$1}', (tester) async {
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

      await pumpKgweboApp(
        tester,
        size: profile.$2,
        config: testConfig(anonKey: 'sb_publishable_test'),
        session: const AppSessionGuest(),
        location: AppRoutes.signIn,
      );

      expect(tester.takeException(), isNull);
      expect(overflows, isEmpty, reason: overflows.join('\n'));
      expect(find.byType(SignInScreen), findsOneWidget);
      expect(find.text('Sign in'), findsWidgets);
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });
  }

  testWidgets('onboarding form scrolls on a short landscape screen', (
    tester,
  ) async {
    const user = AuthUser(
      id: 'user-1',
      email: 'owner@example.com',
      emailConfirmed: true,
    );
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

    await pumpKgweboApp(
      tester,
      size: const Size(800, 360),
      config: testConfig(anonKey: 'sb_publishable_test'),
      session: const AppSessionNeedsOnboarding(user),
      location: AppRoutes.onboarding,
    );

    expect(tester.takeException(), isNull);
    expect(overflows, isEmpty, reason: overflows.join('\n'));
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsWidgets);
    await tester.ensureVisible(find.text('Save and continue'));
    expect(find.text('Save and continue'), findsOneWidget);
  });
}
