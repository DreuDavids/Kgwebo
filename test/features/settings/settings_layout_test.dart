import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/app/config/config_providers.dart';
import 'package:kgwebo/app/router.dart';
import 'package:kgwebo/app/routes.dart';
import 'package:kgwebo/app/theme/kgwebo_theme.dart';
import 'package:kgwebo/features/authentication/application/session_controller.dart';
import 'package:kgwebo/features/authentication/domain/app_session.dart';
import 'package:kgwebo/features/authentication/domain/auth_user.dart';
import 'package:kgwebo/features/onboarding/domain/business_profile.dart';
import 'package:kgwebo/features/settings/presentation/settings_screen.dart';
import 'package:kgwebo/features/shell/app_shell.dart';
import 'package:kgwebo/shared/widgets/kgwebo_button.dart';

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
  const session = AppSessionReady(user: user, business: business);

  Future<List<String>> pumpSettings(
    WidgetTester tester, {
    required Size size,
  }) async {
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

    await setSurface(tester, size);
    final router = createAppRouter(
      initialLocation: AppRoutes.settings,
      currentSession: () => session,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          memoryDatabaseOverride(),
          appConfigProvider.overrideWithValue(
            testConfig(anonKey: 'sb_publishable_test'),
          ),
          appSessionProvider.overrideWith((ref) => session),
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
          syncCoordinatorProvider.overrideWith((ref) => null),
        ],
        child: MaterialApp.router(
          theme: KgweboTheme.light(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return overflows;
  }

  testWidgets(
    'compact Settings shows Review pending changes without overflow',
    (tester) async {
      const size = Size(320, 568);
      final overflows = await pumpSettings(tester, size: size);

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.byType(AppShell), findsOneWidget);
      expect(find.text('Pending changes'), findsOneWidget);
      final review = find.text('Review pending changes');
      expect(review, findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(overflows, isEmpty, reason: overflows.join('\n'));

      final rect = tester.getRect(review);
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(size.width + 0.5));
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(size.height + 0.5));
      expect(
        find.descendant(of: find.byType(KgweboButton), matching: review),
        findsOneWidget,
      );
    },
  );

  testWidgets('wider Settings keeps pending review readable', (tester) async {
    const size = Size(1024, 768);
    final overflows = await pumpSettings(tester, size: size);

    expect(find.text('Review pending changes'), findsOneWidget);
    expect(find.text('Pending changes'), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(overflows, isEmpty, reason: overflows.join('\n'));
  });
}
