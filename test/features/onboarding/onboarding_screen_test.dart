import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/app/config/config_providers.dart';
import 'package:kgwebo/app/theme/kgwebo_theme.dart';
import 'package:kgwebo/features/authentication/application/session_controller.dart';
import 'package:kgwebo/features/authentication/domain/auth_user.dart';
import 'package:kgwebo/features/onboarding/presentation/onboarding_screen.dart';

import '../../helpers/fake_auth.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_config.dart';

void main() {
  const user = AuthUser(
    id: 'user-1',
    email: 'owner@example.com',
    emailConfirmed: true,
  );

  testWidgets('onboarding requires name and type before saving', (
    tester,
  ) async {
    final onboarding = FakeOnboardingRepository();
    await setSurface(tester, const Size(360, 800));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            testConfig(anonKey: 'sb_publishable_test'),
          ),
          authRepositoryProvider.overrideWith(
            (ref) => FakeAuthRepository(user: user),
          ),
          onboardingRepositoryProvider.overrideWith((ref) => onboarding),
        ],
        child: MaterialApp(
          theme: KgweboTheme.light(),
          home: const OnboardingScreen(),
        ),
      ),
    );

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('Enter your business name.'), findsOneWidget);
    expect(find.text('Choose a business type.'), findsOneWidget);
    expect(onboarding.saveCalls, 0);
  });
}
