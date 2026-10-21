import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/app/config/config_providers.dart';
import 'package:kgwebo/app/theme/kgwebo_theme.dart';
import 'package:kgwebo/features/authentication/application/session_controller.dart';
import 'package:kgwebo/features/authentication/domain/app_session.dart';
import 'package:kgwebo/features/authentication/domain/auth_user.dart';
import 'package:kgwebo/features/onboarding/domain/business_profile.dart';
import 'package:kgwebo/features/obligations/presentation/obligation_form_screen.dart';

import '../../helpers/fake_auth.dart';
import '../../helpers/fake_obligations.dart';
import '../../helpers/fake_transactions.dart';
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
  );

  Future<FakeObligationRepository> pumpForm(
    WidgetTester tester, {
    FakeObligationRepository? repository,
    Size size = const Size(360, 800),
  }) async {
    final obligations = repository ?? FakeObligationRepository();
    await setSurface(tester, size);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            testConfig(anonKey: 'sb_publishable_test'),
          ),
          appSessionProvider.overrideWith(
            (ref) => AppSessionReady(user: user, business: business),
          ),
          currentOwnerIdProvider.overrideWithValue(user.id),
          authRepositoryProvider.overrideWith(
            (ref) => FakeAuthRepository(user: user),
          ),
          onboardingRepositoryProvider.overrideWith(
            (ref) => FakeOnboardingRepository(business: business),
          ),
          transactionRepositoryProvider.overrideWith(
            (ref) => FakeTransactionRepository(),
          ),
          obligationRepositoryProvider.overrideWith((ref) => obligations),
        ],
        child: MaterialApp(
          theme: KgweboTheme.light(),
          home: const ObligationFormScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return obligations;
  }

  testWidgets('form validates empty amount', (tester) async {
    await pumpForm(tester);
    await tester.enterText(find.byType(TextField).first, 'Shop rent');
    await tester.ensureVisible(find.text('Save commitment'));
    await tester.tap(find.text('Save commitment'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Enter a positive amount in pula and thebe, for example 50.00.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('form saves a valid commitment once', (tester) async {
    final repository = await pumpForm(tester);
    await tester.enterText(find.byType(TextField).first, 'Shop rent');
    await tester.enterText(find.byType(TextField).at(1), '800.00');
    await tester.ensureVisible(find.text('Save commitment'));
    await tester.tap(find.text('Save commitment'));
    await tester.pumpAndSettle();
    expect(repository.createCalls, 1);
    expect(repository.items.single.amountMinor, 80000);
    expect(repository.items.single.title, 'Shop rent');
  });

  testWidgets('duplicate taps while saving do not create two rows', (
    tester,
  ) async {
    final repository =
        FakeObligationRepository()
          ..createDelay = const Duration(milliseconds: 400);
    await pumpForm(tester, repository: repository);
    await tester.enterText(find.byType(TextField).first, 'Shop rent');
    await tester.enterText(find.byType(TextField).at(1), '800.00');
    await tester.ensureVisible(find.text('Save commitment'));
    await tester.tap(find.text('Save commitment'));
    await tester.tap(find.text('Save commitment'));
    await tester.pumpAndSettle();
    expect(repository.createCalls, 1);
    expect(repository.items, hasLength(1));
  });
}
