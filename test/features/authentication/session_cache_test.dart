import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/persistence/business_cache.dart';
import 'package:kgwebo/core/persistence/kgwebo_database.dart';
import 'package:kgwebo/features/authentication/application/session_controller.dart';
import 'package:kgwebo/features/authentication/domain/app_session.dart';
import 'package:kgwebo/features/authentication/domain/auth_failure.dart';
import 'package:kgwebo/features/authentication/domain/auth_user.dart';
import 'package:kgwebo/features/onboarding/data/cached_onboarding_repository.dart';
import 'package:kgwebo/features/onboarding/domain/business_profile.dart';

import '../../helpers/fake_auth.dart';
import '../../helpers/test_config.dart';

void main() {
  const user = AuthUser(
    id: 'user-a',
    email: 'owner@example.com',
    emailConfirmed: true,
  );
  const business = BusinessProfile(
    id: 'biz-a',
    ownerId: 'user-a',
    name: 'Kgale Stall',
    businessType: 'Informal trader',
    countryCode: 'BW',
    currencyCode: 'BWP',
    openingBalanceMinor: 200000,
  );

  test(
    'confirmed cache can restore a ready session when remote is down',
    () async {
      final database = KgweboDatabase.memory();
      addTearDown(database.close);
      final cache = BusinessCache(database);
      await cache.upsertConfirmed(business);
      final remote = FakeOnboardingRepository(
        business: business,
        ownerId: 'user-a',
      )..findError = const AuthFailure.network();
      final repository = CachedOnboardingRepository(
        remote: remote,
        cache: cache,
        currentOwnerId: () => 'user-a',
      );
      final controller = SessionController(
        config: testConfig(anonKey: 'sb_publishable_test'),
        auth: FakeAuthRepository(user: user),
        onboarding: repository,
      );
      await pumpEventQueue();
      expect(controller.state, isA<AppSessionReady>());
      final ready = controller.state as AppSessionReady;
      expect(ready.isStale, isTrue);
      expect(ready.business.openingBalanceMinor, 200000);
    },
  );

  test('unverified empty cache does not complete onboarding', () async {
    final database = KgweboDatabase.memory();
    addTearDown(database.close);
    final remote = FakeOnboardingRepository(ownerId: 'user-a')
      ..findError = const AuthFailure.network();
    final repository = CachedOnboardingRepository(
      remote: remote,
      cache: BusinessCache(database),
      currentOwnerId: () => 'user-a',
    );
    final controller = SessionController(
      config: testConfig(anonKey: 'sb_publishable_test'),
      auth: FakeAuthRepository(user: user),
      onboarding: repository,
    );
    await pumpEventQueue();
    expect(controller.state, isA<AppSessionFailure>());
  });

  test(
    'sign-out clears in-memory session without deleting the owner cache',
    () async {
      final database = KgweboDatabase.memory();
      addTearDown(database.close);
      final cache = BusinessCache(database);
      final remote = FakeOnboardingRepository(
        business: business,
        ownerId: 'user-a',
      );
      final repository = CachedOnboardingRepository(
        remote: remote,
        cache: cache,
        currentOwnerId: () => 'user-a',
      );
      final auth = FakeAuthRepository(user: user);
      final controller = SessionController(
        config: testConfig(anonKey: 'sb_publishable_test'),
        auth: auth,
        onboarding: repository,
      );
      await pumpEventQueue();
      expect(controller.state, isA<AppSessionReady>());
      await controller.signOut();
      expect(controller.state, isA<AppSessionGuest>());
      expect(await cache.findConfirmedForOwner('user-a'), isNotNull);
    },
  );
}

Future<void> pumpEventQueue() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}
