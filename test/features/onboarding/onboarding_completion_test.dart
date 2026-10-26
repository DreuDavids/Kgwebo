import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/validation/onboarding_validators.dart';
import 'package:kgwebo/features/onboarding/domain/business_profile.dart';
import 'package:kgwebo/features/onboarding/domain/onboarding_draft.dart';

void main() {
  test('a business with required fields is complete', () {
    const profile = BusinessProfile(
      id: 'biz-1',
      ownerId: 'user-1',
      name: 'Kgale Stall',
      businessType: 'Informal trader',
      countryCode: 'BW',
      currencyCode: 'BWP',
      openingBalanceMinor: 0,
    );
    expect(profile.isOnboardingComplete, isTrue);
  });

  test('missing name or type is not complete', () {
    const profile = BusinessProfile(
      id: 'biz-1',
      ownerId: 'user-1',
      name: '  ',
      businessType: '',
      countryCode: 'BW',
      currencyCode: 'BWP',
      openingBalanceMinor: 0,
    );
    expect(profile.isOnboardingComplete, isFalse);
  });

  test('draft validation requires name and type', () {
    const draft = OnboardingDraft(
      name: '',
      businessType: '',
      countryCode: 'BW',
      currencyCode: 'BWP',
      openingCashText: '0',
    );
    final errors = validateOnboardingDraft(draft);
    expect(errors.name, isNotNull);
    expect(errors.businessType, isNotNull);
  });

  test('opening cash must be a non-negative amount of pula', () {
    const draft = OnboardingDraft(
      name: 'Kgale Stall',
      businessType: 'Informal trader',
      countryCode: 'BW',
      currencyCode: 'BWP',
      openingCashText: '-5',
    );
    expect(validateOnboardingDraft(draft).openingCash, isNotNull);
    expect(
      validateOnboardingDraft(
        draft.copyWith(openingCashText: 'not-a-number'),
      ).openingCash,
      isNotNull,
    );
    expect(
      validateOnboardingDraft(
        draft.copyWith(openingCashText: '12.50'),
      ).hasErrors,
      isFalse,
    );
  });

  test('empty opening cash becomes zero minor units', () {
    expect(parseOpeningBalanceMinor(''), 0);
    expect(parseOpeningBalanceMinor('  '), 0);
    expect(parseOpeningBalanceMinor('10.50'), 1050);
  });

  test('opening cash uses integer minor units, not binary doubles', () {
    expect(parseOpeningBalanceMinor('0'), 0);
    expect(parseOpeningBalanceMinor('0.00'), 0);
    expect(parseOpeningBalanceMinor('0.10'), 10);
    expect(parseOpeningBalanceMinor('0.20'), 20);
    expect(
      parseOpeningBalanceMinor('0.10') + parseOpeningBalanceMinor('0.20'),
      30,
    );
    expect(tryParseOpeningBalanceMinor('1e2'), isNull);
    expect(tryParseOpeningBalanceMinor('12.505'), isNull);
  });
}
