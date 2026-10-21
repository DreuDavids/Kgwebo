import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/app/config/config_providers.dart';
import 'package:kgwebo/app/theme/kgwebo_theme.dart';
import 'package:kgwebo/features/authentication/application/session_controller.dart';
import 'package:kgwebo/features/authentication/domain/app_session.dart';
import 'package:kgwebo/features/authentication/domain/auth_failure.dart';
import 'package:kgwebo/features/authentication/domain/auth_user.dart';
import 'package:kgwebo/features/dashboard/presentation/dashboard_screen.dart';
import 'package:kgwebo/features/onboarding/domain/business_profile.dart';

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

  Future<void> pumpDashboard(
    WidgetTester tester, {
    FakeObligationRepository? obligations,
    FakeRecommendationRepository? recommendations,
  }) async {
    await setSurface(tester, const Size(360, 800));
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
          obligationRepositoryProvider.overrideWith(
            (ref) => obligations ?? FakeObligationRepository(),
          ),
          productRepositoryProvider.overrideWith(
            (ref) => FakeProductRepository(),
          ),
          recommendationRepositoryProvider.overrideWith(
            (ref) => recommendations ?? FakeRecommendationRepository(),
          ),
        ],
        child: MaterialApp(
          theme: KgweboTheme.light(),
          home: const DashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('14-day horizon includes a bill that 7 days excludes', (
    tester,
  ) async {
    final today = DateTime.now();
    final dueBeyondSeven = DateTime(today.year, today.month, today.day + 10);
    final obligations =
        FakeObligationRepository()
          ..items.add(sampleObligation(amount: 80000, dueOn: dueBeyondSeven));
    await pumpDashboard(tester, obligations: obligations);
    await selectDashboardTab(tester, 'Outlook');
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 1200));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('7 days'));
    await tester.pumpAndSettle();
    expect(find.text('7 days'), findsOneWidget);
    expect(find.text('14 days'), findsOneWidget);
    expect(find.text('30 days'), findsOneWidget);
    expect(find.text('P 1,200.00'), findsWidgets);
    expect(find.textContaining('Incoming cash is not forecast'), findsWidgets);
    await tester.tap(find.text('7 days'));
    await tester.pumpAndSettle();
    expect(find.text('P 1,200.00'), findsNothing);
    expect(find.textContaining('fall after this window'), findsWidgets);
  });

  testWidgets('overdue commitment surfaces an evidence-backed recommendation', (
    tester,
  ) async {
    final obligations =
        FakeObligationRepository()
          ..items.add(
            sampleObligation(amount: 80000, dueOn: DateTime(2026, 1, 1)),
          );
    await pumpDashboard(tester, obligations: obligations);
    expect(find.text('An unpaid commitment is overdue'), findsOneWidget);
    expect(find.textContaining('P 800.00'), findsWidgets);
  });

  testWidgets('failed recommendation refresh is not an empty list', (
    tester,
  ) async {
    final recommendations =
        FakeRecommendationRepository()..failReads = const AuthFailure.network();
    await pumpDashboard(tester, recommendations: recommendations);
    expect(
      find.textContaining('Recommendations could not be loaded'),
      findsOneWidget,
    );
    expect(find.text('No active recommendations'), findsNothing);
  });
}
