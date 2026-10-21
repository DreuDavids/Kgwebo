import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/validation/onboarding_validators.dart';
import 'package:kgwebo/features/onboarding/domain/business_profile.dart';
import 'package:kgwebo/features/onboarding/domain/onboarding_draft.dart';

void main() {
  const profile = BusinessProfile(
    id: 'biz-1',
    ownerId: 'user-1',
    name: 'Kgale Stall',
    businessType: 'Informal trader',
    countryCode: 'BW',
    currencyCode: 'BWP',
    openingBalanceMinor: 200000,
    description: 'Roadside fruit',
    contactPhone: '71234567',
  );

  test('fromMap round-trips remote columns including opening cash', () {
    final mapped = BusinessProfile.fromMap({
      'id': 'biz-1',
      'owner_id': 'user-1',
      'name': 'Kgale Stall',
      'business_type': 'Informal trader',
      'country_code': 'BW',
      'currency_code': 'BWP',
      'opening_balance_minor': 200000,
      'description': 'Roadside fruit',
      'started_on': '2024-03-01',
      'contact_phone': '71234567',
      'created_at': '2024-03-01T08:00:00.000Z',
      'updated_at': '2024-03-02T08:00:00.000Z',
    });
    expect(mapped.id, 'biz-1');
    expect(mapped.ownerId, 'user-1');
    expect(mapped.openingBalanceMinor, 200000);
    expect(mapped.startedOn, isNotNull);
    expect(mapped.belongsTo('user-1'), isTrue);
    expect(mapped.belongsTo('user-2'), isFalse);
  });

  test('draft write map never includes owner_id', () {
    final draft = OnboardingDraft.fromProfile(profile);
    final payload = draft.toWriteMap(
      openingBalanceMinor: draft.openingBalanceMinor,
    );
    expect(payload.containsKey('owner_id'), isFalse);
    expect(payload['opening_balance_minor'], 200000);
    expect(payload['name'], 'Kgale Stall');
  });

  test('fromProfile preserves opening cash for the edit form', () {
    final draft = OnboardingDraft.fromProfile(profile);
    expect(draft.openingCashText, '2000.00');
    expect(parseOpeningBalanceMinor(draft.openingCashText), 200000);
  });

  test('validation still rejects a negative opening cash', () {
    final errors = validateOnboardingDraft(
      OnboardingDraft.fromProfile(profile).copyWith(openingCashText: '-1'),
    );
    expect(errors.openingCash, isNotNull);
  });
}
