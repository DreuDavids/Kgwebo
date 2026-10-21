import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/app/config/config_providers.dart';
import 'package:kgwebo/app/theme/kgwebo_theme.dart';
import 'package:kgwebo/features/authentication/application/session_controller.dart';
import 'package:kgwebo/features/authentication/domain/app_session.dart';
import 'package:kgwebo/features/authentication/domain/auth_user.dart';
import 'package:kgwebo/features/onboarding/domain/business_profile.dart';
import 'package:kgwebo/features/recommendations/presentation/recommendations_screen.dart';

import '../../helpers/fake_auth.dart';
import '../../helpers/fake_obligations.dart';
import '../../helpers/fake_products.dart';
import '../../helpers/fake_recommendations.dart';
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

  testWidgets('recommendations screen stays usable at 320 logical pixels', (
    tester,
  ) async {
    await setSurface(tester, const Size(320, 568));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          memoryDatabaseOverride(),
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
          obligationRepositoryProvider.overrideWith(
            (ref) =>
                FakeObligationRepository()
                  ..items.add(
                    sampleObligation(
                      amount: 80000,
                      dueOn: DateTime(2026, 1, 1),
                    ),
                  ),
          ),
          productRepositoryProvider.overrideWith(
            (ref) => FakeProductRepository(),
          ),
          recommendationRepositoryProvider.overrideWith(
            (ref) => FakeRecommendationRepository(),
          ),
        ],
        child: MaterialApp(
          theme: KgweboTheme.light(),
          home: const RecommendationsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('An unpaid commitment is overdue'), findsOneWidget);
    expect(find.text('Dismiss'), findsOneWidget);

    tester.view.viewInsets = const FakeViewPadding(bottom: 240);
    addTearDown(tester.view.resetViewInsets);
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text('Dismiss'),
      80,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dismiss'));
    await tester.pumpAndSettle();
    expect(find.text('An unpaid commitment is overdue'), findsNothing);
  });
}
