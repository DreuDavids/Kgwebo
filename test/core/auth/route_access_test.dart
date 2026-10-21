import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/app/config/app_environment.dart';
import 'package:kgwebo/app/routes.dart';
import 'package:kgwebo/core/auth/route_access.dart';
import 'package:kgwebo/features/authentication/domain/app_session.dart';
import 'package:kgwebo/features/authentication/domain/auth_user.dart';
import 'package:kgwebo/features/onboarding/domain/business_profile.dart';

void main() {
  const user = AuthUser(
    id: 'user-1',
    email: 'owner@example.com',
    emailConfirmed: true,
  );
  final business = BusinessProfile(
    id: 'biz-1',
    ownerId: 'user-1',
    name: 'Kgale Stall',
    businessType: 'Informal trader',
    countryCode: 'BW',
    currencyCode: 'BWP',
    openingBalanceMinor: 0,
  );

  test('loading session stays on the session screen', () {
    expect(
      redirectFor(const AppSessionLoading(), AppRoutes.dashboard),
      AppRoutes.session,
    );
    expect(redirectFor(const AppSessionLoading(), AppRoutes.session), isNull);
  });

  test('preview sessions can open the shell and leave auth screens', () {
    expect(
      redirectFor(
        const AppSessionPreview(AppRuntimeMode.demo),
        AppRoutes.dashboard,
      ),
      isNull,
    );
    expect(
      redirectFor(
        const AppSessionPreview(AppRuntimeMode.local),
        AppRoutes.signIn,
      ),
      AppRoutes.dashboard,
    );
  });

  test('guests cannot open the business profile', () {
    expect(
      redirectFor(const AppSessionGuest(), AppRoutes.businessProfile),
      AppRoutes.welcome,
    );
    expect(
      redirectFor(const AppSessionGuest(), AppRoutes.businessProfileEdit),
      AppRoutes.welcome,
    );
  });

  test('guests cannot open protected business routes', () {
    expect(
      redirectFor(const AppSessionGuest(), AppRoutes.dashboard),
      AppRoutes.welcome,
    );
    expect(
      redirectFor(const AppSessionGuest(), AppRoutes.transactions),
      AppRoutes.welcome,
    );
    expect(redirectFor(const AppSessionGuest(), AppRoutes.signIn), isNull);
    expect(redirectFor(const AppSessionGuest(), AppRoutes.welcome), isNull);
  });

  test('email confirmation and recovery routes win over the shell', () {
    expect(
      redirectFor(
        const AppSessionNeedsEmailConfirmation(email: 'owner@example.com'),
        AppRoutes.dashboard,
      ),
      AppRoutes.confirmEmail,
    );
    expect(
      redirectFor(const AppSessionPasswordRecovery(user), AppRoutes.dashboard),
      AppRoutes.resetPassword,
    );
  });

  test('authenticated users with no business go to onboarding', () {
    expect(
      redirectFor(const AppSessionNeedsOnboarding(user), AppRoutes.dashboard),
      AppRoutes.onboarding,
    );
    expect(
      redirectFor(const AppSessionNeedsOnboarding(user), AppRoutes.signIn),
      AppRoutes.onboarding,
    );
    expect(
      redirectFor(const AppSessionNeedsOnboarding(user), AppRoutes.onboarding),
      isNull,
    );
  });

  test('ready users skip auth and onboarding screens', () {
    final session = AppSessionReady(user: user, business: business);
    expect(redirectFor(session, AppRoutes.dashboard), isNull);
    expect(redirectFor(session, AppRoutes.welcome), AppRoutes.dashboard);
    expect(redirectFor(session, AppRoutes.onboarding), AppRoutes.dashboard);
    expect(redirectFor(session, AppRoutes.signIn), AppRoutes.dashboard);
  });

  test('unknown locations are not rewritten by the policy', () {
    expect(
      redirectFor(const AppSessionGuest(), '/this-route-does-not-exist'),
      isNull,
    );
  });
}
