import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/app/config/config_providers.dart';
import 'package:kgwebo/app/theme/kgwebo_theme.dart';
import 'package:kgwebo/features/authentication/application/session_controller.dart';
import 'package:kgwebo/features/authentication/domain/app_session.dart';
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

  testWidgets('reporting period carousel is edge to edge', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

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
            (ref) => FakeObligationRepository(),
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
          home: const DashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final carousel = find.byKey(const ValueKey('dashboard-period-carousel'));
    expect(carousel, findsOneWidget);

    final carouselRect = tester.getRect(carousel);
    final bodyRect = tester.getRect(find.byType(CustomScrollView));
    expect(carouselRect.left, bodyRect.left);
    expect(carouselRect.right, bodyRect.right);
  });
}
