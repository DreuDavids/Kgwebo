import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/app/config/config_providers.dart';
import 'package:kgwebo/app/theme/kgwebo_theme.dart';
import 'package:kgwebo/features/authentication/application/session_controller.dart';
import 'package:kgwebo/features/authentication/domain/app_session.dart';
import 'package:kgwebo/features/authentication/domain/auth_user.dart';
import 'package:kgwebo/features/business/presentation/business_profile_edit_screen.dart';
import 'package:kgwebo/features/business/presentation/business_profile_screen.dart';
import 'package:kgwebo/features/onboarding/domain/business_profile.dart';

import '../../helpers/fake_auth.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_config.dart';

void main() {
  const user = AuthUser(
    id: 'user-1',
    email: 'owner@example.com',
    emailConfirmed: true,
  );
  const business = BusinessProfile(
    id: 'biz-1',
    ownerId: 'user-1',
    name: 'Kgale Stall',
    businessType: 'Informal trader',
    countryCode: 'BW',
    currencyCode: 'BWP',
    openingBalanceMinor: 0,
  );

  const profiles = <(String, Size)>[
    ('compact phone portrait', Size(320, 568)),
    ('standard phone portrait', Size(360, 800)),
    ('phone landscape', Size(800, 360)),
    ('tablet portrait', Size(768, 1024)),
    ('tablet landscape', Size(1024, 768)),
  ];

  Future<void> pumpAt(WidgetTester tester, Size size, Widget home) async {
    final onboarding = FakeOnboardingRepository(business: business);
    await setSurface(tester, size);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            testConfig(anonKey: 'sb_publishable_test'),
          ),
          appSessionProvider.overrideWith(
            (ref) => const AppSessionReady(user: user, business: business),
          ),
          currentOwnerIdProvider.overrideWithValue(user.id),
          authRepositoryProvider.overrideWith(
            (ref) => FakeAuthRepository(user: user),
          ),
          onboardingRepositoryProvider.overrideWith((ref) => onboarding),
          sessionControllerProvider.overrideWith(
            (ref) => SessionController(
              config: testConfig(anonKey: 'sb_publishable_test'),
              auth: FakeAuthRepository(user: user),
              onboarding: onboarding,
            ),
          ),
        ],
        child: MaterialApp(theme: KgweboTheme.light(), home: home),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final profile in profiles) {
    testWidgets('profile remains usable at ${profile.$1}', (tester) async {
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

      await pumpAt(tester, profile.$2, const BusinessProfileScreen());

      expect(tester.takeException(), isNull);
      expect(overflows, isEmpty, reason: overflows.join('\n'));
      expect(find.byType(BusinessProfileScreen), findsOneWidget);
      expect(find.text('Business profile'), findsWidgets);
      expect(find.text('Edit profile'), findsOneWidget);
      expect(find.byType(ErrorWidget), findsNothing);
    });

    testWidgets('edit form scrolls at ${profile.$1}', (tester) async {
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

      await pumpAt(tester, profile.$2, const BusinessProfileEditScreen());

      expect(tester.takeException(), isNull);
      expect(overflows, isEmpty, reason: overflows.join('\n'));
      expect(find.text('Edit business'), findsWidgets);
      expect(find.byType(SingleChildScrollView), findsWidgets);
      expect(find.text('Save'), findsWidgets);
      expect(find.text('Cancel'), findsWidgets);
    });
  }
}
