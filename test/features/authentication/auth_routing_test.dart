import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/app/routes.dart';
import 'package:kgwebo/features/authentication/domain/app_session.dart';
import 'package:kgwebo/features/authentication/domain/auth_user.dart';
import 'package:kgwebo/features/authentication/presentation/welcome_screen.dart';
import 'package:kgwebo/features/dashboard/presentation/dashboard_screen.dart';
import 'package:kgwebo/features/onboarding/domain/business_profile.dart';
import 'package:kgwebo/features/onboarding/presentation/onboarding_screen.dart';

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

  testWidgets('live guest cannot open the dashboard', (tester) async {
    await pumpKgweboApp(
      tester,
      config: testConfig(anonKey: 'sb_publishable_test'),
      session: const AppSessionGuest(),
      location: AppRoutes.dashboard,
    );

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(DashboardScreen), findsNothing);
  });

  testWidgets('ready users skip sign-in', (tester) async {
    await pumpKgweboApp(
      tester,
      config: testConfig(anonKey: 'sb_publishable_test'),
      session: const AppSessionReady(user: user, business: business),
      location: AppRoutes.signIn,
    );

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.textContaining('Kgale Stall'), findsWidgets);
  });

  testWidgets('authenticated users without a business land on onboarding', (
    tester,
  ) async {
    await pumpKgweboApp(
      tester,
      config: testConfig(anonKey: 'sb_publishable_test'),
      session: const AppSessionNeedsOnboarding(user),
      location: AppRoutes.dashboard,
    );

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(DashboardScreen), findsNothing);
  });

  testWidgets('demo preview still opens the labelled shell', (tester) async {
    await pumpKgweboApp(
      tester,
      config: testConfig(appEnv: 'demo', anonKey: 'sb_publishable_test'),
      location: AppRoutes.dashboard,
    );

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.textContaining('This is a demo'), findsOneWidget);
  });
}
