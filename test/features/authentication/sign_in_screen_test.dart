import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/app/config/config_providers.dart';
import 'package:kgwebo/app/theme/kgwebo_theme.dart';
import 'package:kgwebo/features/authentication/application/session_controller.dart';
import 'package:kgwebo/features/authentication/domain/auth_failure.dart';
import 'package:kgwebo/features/authentication/presentation/forgot_password_screen.dart';
import 'package:kgwebo/features/authentication/presentation/sign_in_screen.dart';
import 'package:kgwebo/features/authentication/presentation/sign_up_screen.dart';

import '../../helpers/fake_auth.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_config.dart';

Widget _harness({
  required Widget child,
  FakeAuthRepository? auth,
  FakeOnboardingRepository? onboarding,
}) {
  return ProviderScope(
    overrides: [
      appConfigProvider.overrideWithValue(
        testConfig(anonKey: 'sb_publishable_test'),
      ),
      authRepositoryProvider.overrideWith(
        (ref) => auth ?? FakeAuthRepository(),
      ),
      onboardingRepositoryProvider.overrideWith(
        (ref) => onboarding ?? FakeOnboardingRepository(),
      ),
    ],
    child: MaterialApp(theme: KgweboTheme.light(), home: child),
  );
}

void main() {
  testWidgets('sign-in validates empty fields without submitting', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    await setSurface(tester, const Size(360, 800));
    await tester.pumpWidget(_harness(child: const SignInScreen(), auth: auth));

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();

    expect(find.text('Enter your email address.'), findsOneWidget);
    expect(find.text('Enter a password.'), findsOneWidget);
    expect(auth.signInCalls, 0);
  });

  testWidgets(
    'sign-in shows auth errors and keeps submit disabled while loading',
    (tester) async {
      final auth =
          FakeAuthRepository()
            ..nextError = const AuthFailure('Email or password is incorrect.');
      await setSurface(tester, const Size(360, 800));
      await tester.pumpWidget(
        _harness(child: const SignInScreen(), auth: auth),
      );

      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'owner@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'correct1',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Email or password is incorrect.'), findsOneWidget);
      expect(auth.signInCalls, 1);
    },
  );

  testWidgets('password visibility toggle changes obscureText', (tester) async {
    await setSurface(tester, const Size(360, 800));
    await tester.pumpWidget(_harness(child: const SignInScreen()));

    final field = tester.widget<TextField>(
      find.widgetWithText(TextField, 'Password'),
    );
    expect(field.obscureText, isTrue);

    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();

    final revealed = tester.widget<TextField>(
      find.widgetWithText(TextField, 'Password'),
    );
    expect(revealed.obscureText, isFalse);
  });

  testWidgets('sign-up validates confirmation mismatch', (tester) async {
    final auth = FakeAuthRepository();
    await setSurface(tester, const Size(360, 800));
    await tester.pumpWidget(_harness(child: const SignUpScreen(), auth: auth));

    await tester.enterText(
      find.widgetWithText(TextField, 'Email'),
      'owner@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'correct1',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Confirm password'),
      'other123',
    );
    await tester.tap(find.text('Create account'));
    await tester.pump();

    expect(find.text('Passwords do not match.'), findsOneWidget);
    expect(auth.signUpCalls, 0);
  });

  testWidgets('password reset request validates email', (tester) async {
    await setSurface(tester, const Size(360, 800));
    await tester.pumpWidget(_harness(child: const ForgotPasswordScreen()));

    await tester.tap(find.text('Send reset link'));
    await tester.pump();
    expect(find.text('Enter your email address.'), findsOneWidget);
  });
}
