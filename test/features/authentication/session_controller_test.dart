import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/app/config/app_environment.dart';
import 'package:kgwebo/features/authentication/application/session_controller.dart';
import 'package:kgwebo/features/authentication/domain/app_session.dart';
import 'package:kgwebo/features/authentication/domain/auth_failure.dart';
import 'package:kgwebo/features/authentication/domain/auth_user.dart';
import 'package:kgwebo/features/onboarding/domain/business_profile.dart';
import 'package:kgwebo/features/onboarding/domain/onboarding_draft.dart';

import '../../helpers/fake_auth.dart';
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

  test('preview config never opens a live session', () {
    final controller = SessionController(
      config: testConfig(appEnv: 'demo', anonKey: 'sb_publishable_test'),
      auth: FakeAuthRepository(user: user),
      onboarding: FakeOnboardingRepository(business: business),
    );
    expect(controller.state, isA<AppSessionPreview>());
    expect((controller.state as AppSessionPreview).mode, AppRuntimeMode.demo);
  });

  test('restores an authenticated user with a business', () async {
    final controller = SessionController(
      config: testConfig(anonKey: 'sb_publishable_test'),
      auth: FakeAuthRepository(user: user),
      onboarding: FakeOnboardingRepository(business: business),
    );
    await pumpEventQueue();
    expect(controller.state, isA<AppSessionReady>());
  });

  test(
    'restores an authenticated user without a business to onboarding',
    () async {
      final controller = SessionController(
        config: testConfig(anonKey: 'sb_publishable_test'),
        auth: FakeAuthRepository(user: user),
        onboarding: FakeOnboardingRepository(),
      );
      await pumpEventQueue();
      expect(controller.state, isA<AppSessionNeedsOnboarding>());
    },
  );

  test('sign-in failure does not mark the user authenticated', () async {
    final auth =
        FakeAuthRepository()
          ..nextError = const AuthFailure('Email or password is incorrect.');
    final controller = SessionController(
      config: testConfig(anonKey: 'sb_publishable_test'),
      auth: auth,
      onboarding: FakeOnboardingRepository(),
    );
    await pumpEventQueue();
    expect(controller.state, isA<AppSessionGuest>());

    await expectLater(
      controller.signIn(email: 'owner@example.com', password: 'wrongpass'),
      throwsA(isA<AuthFailure>()),
    );
    expect(controller.state, isA<AppSessionGuest>());
    expect(auth.signInCalls, 1);
  });

  test('sign-out returns to guest', () async {
    final auth = FakeAuthRepository(user: user);
    final controller = SessionController(
      config: testConfig(anonKey: 'sb_publishable_test'),
      auth: auth,
      onboarding: FakeOnboardingRepository(business: business),
    );
    await pumpEventQueue();
    await controller.signOut();
    expect(controller.state, isA<AppSessionGuest>());
    expect(auth.signOutCalls, 1);
  });

  test(
    'onboarding retry updates an existing business instead of duplicating',
    () async {
      final onboarding = FakeOnboardingRepository();
      final controller = SessionController(
        config: testConfig(anonKey: 'sb_publishable_test'),
        auth: FakeAuthRepository(user: user),
        onboarding: onboarding,
      );
      await pumpEventQueue();
      const draft = OnboardingDraft(
        name: 'Kgale Stall',
        businessType: 'Informal trader',
      );
      await controller.completeOnboarding(draft);
      await controller.completeOnboarding(
        draft.copyWith(name: 'Kgale Stall 2'),
      );
      expect(onboarding.saveCalls, 2);
      expect(onboarding.business?.id, 'biz-1');
      expect(onboarding.business?.name, 'Kgale Stall 2');
    },
  );

  test(
    'email confirmation required stays unauthenticated for the shell',
    () async {
      final auth = FakeAuthRepository(requireEmailConfirmation: true);
      final controller = SessionController(
        config: testConfig(anonKey: 'sb_publishable_test'),
        auth: auth,
        onboarding: FakeOnboardingRepository(),
      );
      await pumpEventQueue();
      await controller.signUp(email: 'owner@example.com', password: 'correct1');
      expect(controller.state, isA<AppSessionNeedsEmailConfirmation>());
    },
  );

  test('signup OTP confirmation authenticates the user', () async {
    final auth = FakeAuthRepository(requireEmailConfirmation: true);
    final controller = SessionController(
      config: testConfig(anonKey: 'sb_publishable_test'),
      auth: auth,
      onboarding: FakeOnboardingRepository(),
    );
    await pumpEventQueue();
    await controller.signUp(email: 'owner@example.com', password: 'correct1');

    await controller.verifySignupOtp(
      email: 'owner@example.com',
      token: '123456',
    );
    await pumpEventQueue();

    expect(controller.state, isA<AppSessionNeedsOnboarding>());
    expect(auth.verifySignupOtpCalls, 1);
  });

  test('wrong signup OTP keeps the confirmation session', () async {
    final auth = FakeAuthRepository(requireEmailConfirmation: true);
    final controller = SessionController(
      config: testConfig(anonKey: 'sb_publishable_test'),
      auth: auth,
      onboarding: FakeOnboardingRepository(),
    );
    await pumpEventQueue();
    await controller.signUp(email: 'owner@example.com', password: 'correct1');

    await expectLater(
      controller.verifySignupOtp(email: 'owner@example.com', token: '000000'),
      throwsA(isA<AuthFailure>()),
    );
    expect(controller.state, isA<AppSessionNeedsEmailConfirmation>());
  });

  test('recovery OTP moves the session to password reset', () async {
    final auth = FakeAuthRepository();
    final controller = SessionController(
      config: testConfig(anonKey: 'sb_publishable_test'),
      auth: auth,
      onboarding: FakeOnboardingRepository(),
    );
    await pumpEventQueue();
    await controller.requestPasswordReset('owner@example.com');

    await controller.verifyRecoveryOtp(
      email: 'owner@example.com',
      token: '123456',
    );
    await pumpEventQueue();

    expect(controller.state, isA<AppSessionPasswordRecovery>());
    expect(auth.verifyRecoveryOtpCalls, 1);
  });
}

Future<void> pumpEventQueue() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}
