import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/persistence/business_cache.dart';
import 'package:kgwebo/core/persistence/kgwebo_database.dart';
import 'package:kgwebo/features/authentication/domain/auth_failure.dart';
import 'package:kgwebo/features/onboarding/data/cached_onboarding_repository.dart';
import 'package:kgwebo/features/onboarding/domain/business_profile.dart';
import 'package:kgwebo/features/onboarding/domain/business_snapshot.dart';
import 'package:kgwebo/features/onboarding/domain/onboarding_draft.dart';

import '../../helpers/fake_auth.dart';

void main() {
  late KgweboDatabase database;
  late BusinessCache cache;
  late FakeOnboardingRepository remote;
  late CachedOnboardingRepository repository;
  var ownerId = 'user-a';

  const businessA = BusinessProfile(
    id: 'biz-a',
    ownerId: 'user-a',
    name: 'Kgale Stall',
    businessType: 'Informal trader',
    countryCode: 'BW',
    currencyCode: 'BWP',
    openingBalanceMinor: 200000,
  );
  const businessB = BusinessProfile(
    id: 'biz-b',
    ownerId: 'user-b',
    name: 'Broadhurst Shop',
    businessType: 'Retail shop',
    countryCode: 'BW',
    currencyCode: 'BWP',
    openingBalanceMinor: 9000,
  );

  setUp(() {
    database = KgweboDatabase.memory();
    cache = BusinessCache(database);
    remote = FakeOnboardingRepository(business: businessA, ownerId: 'user-a');
    ownerId = 'user-a';
    repository = CachedOnboardingRepository(
      remote: remote,
      cache: cache,
      currentOwnerId: () => ownerId,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('successful remote reads update the confirmed cache', () async {
    final snapshot = await repository.loadOwnedBusiness();
    expect(snapshot!.origin, BusinessDataOrigin.remote);
    expect(snapshot.profile.openingBalanceMinor, 200000);
    final cached = await cache.findConfirmedForOwner('user-a');
    expect(cached!.id, 'biz-a');
  });

  test('network failures keep confirmed cache and mark it stale', () async {
    await repository.loadOwnedBusiness();
    remote.findError = const AuthFailure.network();
    final snapshot = await repository.loadOwnedBusiness();
    expect(snapshot!.isStale, isTrue);
    expect(snapshot.profile.id, 'biz-a');
    expect(snapshot.profile.openingBalanceMinor, 200000);
  });

  test('network failures without a cache do not invent a business', () async {
    remote.business = null;
    remote.findError = const AuthFailure.network();
    await expectLater(
      repository.loadOwnedBusiness(),
      throwsA(isA<AuthFailure>()),
    );
  });

  test('account switching cannot read the previous owner cache', () async {
    await repository.loadOwnedBusiness();
    ownerId = 'user-b';
    remote.ownerId = 'user-b';
    remote.business = businessB;
    remote.findError = const AuthFailure.network();
    await expectLater(
      repository.loadOwnedBusiness(),
      throwsA(isA<AuthFailure>()),
    );
    expect(await cache.findConfirmedForOwner('user-b'), isNull);
    expect(await cache.findConfirmedForOwner('user-a'), isNotNull);
  });

  test('update keeps the same business id and does not insert', () async {
    await repository.loadOwnedBusiness();
    final updated = await repository.updateExisting(
      businessId: 'biz-a',
      draft: const OnboardingDraft(
        name: 'Kgale Stall 2',
        businessType: 'Informal trader',
        openingCashText: '1500.00',
      ),
    );
    expect(updated.id, 'biz-a');
    expect(updated.ownerId, 'user-a');
    expect(updated.openingBalanceMinor, 150000);
    expect(remote.updateCalls, 1);
    expect(remote.saveCalls, 0);
    final rows = await database.select(database.cachedBusinesses).get();
    expect(rows, hasLength(1));
  });

  test('failed updates retain the last confirmed cache', () async {
    await repository.loadOwnedBusiness();
    remote.nextError = const AuthFailure.network();
    await expectLater(
      repository.updateExisting(
        businessId: 'biz-a',
        draft: const OnboardingDraft(
          name: 'Stolen name',
          businessType: 'Informal trader',
          openingCashText: '0',
        ),
      ),
      throwsA(isA<AuthFailure>()),
    );
    final cached = await cache.findConfirmedForOwner('user-a');
    expect(cached!.name, 'Kgale Stall');
    expect(cached.openingBalanceMinor, 200000);
  });

  test('refuses to update another owner business id', () async {
    await cache.upsertConfirmed(businessA);
    await expectLater(
      repository.updateExisting(
        businessId: 'biz-b',
        draft: const OnboardingDraft(
          name: 'Hijack',
          businessType: 'Informal trader',
        ),
      ),
      throwsA(isA<AuthFailure>()),
    );
  });
}
