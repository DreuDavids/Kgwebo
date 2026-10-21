import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/app/config/config_providers.dart';
import 'package:kgwebo/app/theme/kgwebo_theme.dart';
import 'package:kgwebo/features/authentication/application/session_controller.dart';
import 'package:kgwebo/features/authentication/domain/app_session.dart';
import 'package:kgwebo/features/authentication/domain/auth_failure.dart';
import 'package:kgwebo/features/authentication/domain/auth_user.dart';
import 'package:kgwebo/features/business/presentation/business_profile_edit_screen.dart';
import 'package:kgwebo/features/business/presentation/business_profile_screen.dart';
import 'package:kgwebo/features/onboarding/domain/business_profile.dart';
import 'package:kgwebo/features/onboarding/domain/onboarding_draft.dart';

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
    openingBalanceMinor: 200000,
    description: 'Roadside fruit',
  );

  Future<void> pumpProfile(
    WidgetTester tester, {
    required FakeOnboardingRepository onboarding,
    AppSession? session,
    Size size = const Size(360, 800),
    Widget? home,
  }) async {
    final resolvedSession =
        session ?? AppSessionReady(user: user, business: business);
    await setSurface(tester, size);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            testConfig(anonKey: 'sb_publishable_test'),
          ),
          appSessionProvider.overrideWith((ref) => resolvedSession),
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
        child: MaterialApp(
          theme: KgweboTheme.light(),
          home: home ?? const BusinessProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('displays a loaded business profile', (tester) async {
    await pumpProfile(
      tester,
      onboarding: FakeOnboardingRepository(business: business),
    );
    expect(find.text('Kgale Stall'), findsWidgets);
    expect(find.text('Informal trader'), findsOneWidget);
    expect(find.textContaining('Opening / starting cash'), findsOneWidget);
    expect(find.textContaining('BWP 2,000.00'), findsOneWidget);
    expect(
      find.text('Opening cash is a starting position, not revenue.'),
      findsOneWidget,
    );
  });

  testWidgets('opens the edit form with prefilled values', (tester) async {
    await pumpProfile(
      tester,
      onboarding: FakeOnboardingRepository(business: business),
      home: const BusinessProfileEditScreen(),
    );
    expect(find.text('Edit business'), findsOneWidget);
    expect(find.text('Kgale Stall'), findsWidgets);
    expect(find.text('2000.00'), findsOneWidget);
    expect(find.text('Roadside fruit'), findsOneWidget);
  });

  testWidgets('validation failures stay on the form', (tester) async {
    final onboarding = FakeOnboardingRepository(business: business);
    await pumpProfile(
      tester,
      onboarding: onboarding,
      home: const BusinessProfileEditScreen(),
    );
    await tester.enterText(find.byType(TextField).first, '');
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Enter your business name.'), findsOneWidget);
    expect(onboarding.updateCalls, 0);
  });

  testWidgets('saving updates the existing business', (tester) async {
    final onboarding = FakeOnboardingRepository(business: business);
    await pumpProfile(
      tester,
      onboarding: onboarding,
      home: const BusinessProfileEditScreen(),
    );
    await tester.enterText(find.byType(TextField).first, 'Kgale Stall 2');
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(onboarding.updateCalls, 1);
    expect(onboarding.saveCalls, 0);
    expect(onboarding.business!.id, 'biz-1');
    expect(onboarding.business!.name, 'Kgale Stall 2');
    expect(onboarding.business!.openingBalanceMinor, 200000);
  });

  testWidgets('cancel leaves the saved business unchanged', (tester) async {
    final onboarding = FakeOnboardingRepository(business: business);
    await pumpProfile(
      tester,
      onboarding: onboarding,
      home: const BusinessProfileEditScreen(),
    );
    await tester.enterText(find.byType(TextField).first, 'Changed');
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Discard unsaved changes?'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(onboarding.updateCalls, 0);
    expect(onboarding.business!.name, 'Kgale Stall');
  });

  testWidgets('save shows a loading state', (tester) async {
    final onboarding = _SlowOnboarding(business: business);
    await pumpProfile(
      tester,
      onboarding: onboarding,
      home: const BusinessProfileEditScreen(),
    );
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Saving'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('remote failure keeps the last profile and explains it', (
    tester,
  ) async {
    final onboarding = FakeOnboardingRepository(business: business)
      ..nextError = const AuthFailure.network();
    await pumpProfile(
      tester,
      onboarding: onboarding,
      home: const BusinessProfileEditScreen(),
    );
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Check your connection and try again.'), findsOneWidget);
    expect(onboarding.business!.name, 'Kgale Stall');
    expect(onboarding.business!.openingBalanceMinor, 200000);
  });

  testWidgets('stale cache is labelled honestly', (tester) async {
    await pumpProfile(
      tester,
      onboarding: FakeOnboardingRepository(business: business)
        ..findError = const AuthFailure.network(),
      session: const AppSessionReady(
        user: user,
        business: business,
        isStale: true,
      ),
    );
    expect(find.textContaining('last saved copy'), findsWidgets);
    expect(find.text('Kgale Stall'), findsWidgets);
  });
}

class _SlowOnboarding extends FakeOnboardingRepository {
  _SlowOnboarding({super.business});

  @override
  Future<BusinessProfile> updateExisting({
    required String businessId,
    required OnboardingDraft draft,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 40));
    return super.updateExisting(businessId: businessId, draft: draft);
  }
}
