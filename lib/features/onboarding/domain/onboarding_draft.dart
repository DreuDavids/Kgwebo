import '../../../core/money/minor_units.dart';
import '../../../core/validation/onboarding_validators.dart';
import 'business_profile.dart';

class OnboardingDraft {
  const OnboardingDraft({
    this.name = '',
    this.businessType = '',
    this.countryCode = 'BW',
    this.currencyCode = 'BWP',
    this.openingCashText = '',
    this.description = '',
    this.startedOn,
    this.contactPhone = '',
  });

  final String name;
  final String businessType;
  final String countryCode;
  final String currencyCode;
  final String openingCashText;
  final String description;
  final DateTime? startedOn;
  final String contactPhone;

  factory OnboardingDraft.fromProfile(BusinessProfile profile) {
    return OnboardingDraft(
      name: profile.name,
      businessType: profile.businessType,
      countryCode: profile.countryCode,
      currencyCode: profile.currencyCode,
      openingCashText: MinorUnits.format(
        profile.openingBalanceMinor,
        group: false,
      ),
      description: profile.description ?? '',
      startedOn: profile.startedOn,
      contactPhone: profile.contactPhone ?? '',
    );
  }

  int get openingBalanceMinor => parseOpeningBalanceMinor(openingCashText);

  OnboardingDraft copyWith({
    String? name,
    String? businessType,
    String? countryCode,
    String? currencyCode,
    String? openingCashText,
    String? description,
    DateTime? startedOn,
    String? contactPhone,
    bool clearStartedOn = false,
  }) {
    return OnboardingDraft(
      name: name ?? this.name,
      businessType: businessType ?? this.businessType,
      countryCode: countryCode ?? this.countryCode,
      currencyCode: currencyCode ?? this.currencyCode,
      openingCashText: openingCashText ?? this.openingCashText,
      description: description ?? this.description,
      startedOn: clearStartedOn ? null : (startedOn ?? this.startedOn),
      contactPhone: contactPhone ?? this.contactPhone,
    );
  }

  /// Payload for insert or update. Never includes `owner_id`.
  Map<String, dynamic> toWriteMap({required int openingBalanceMinor}) {
    return {
      'name': name.trim(),
      'business_type': businessType.trim(),
      'country_code': countryCode.trim().toUpperCase(),
      'currency_code': currencyCode.trim().toUpperCase(),
      'opening_balance_minor': openingBalanceMinor,
      'description': description.trim().isEmpty ? null : description.trim(),
      'started_on':
          startedOn == null
              ? null
              : '${startedOn!.year.toString().padLeft(4, '0')}-'
                  '${startedOn!.month.toString().padLeft(2, '0')}-'
                  '${startedOn!.day.toString().padLeft(2, '0')}',
      'contact_phone': contactPhone.trim().isEmpty ? null : contactPhone.trim(),
    };
  }

  Map<String, dynamic> toInsertMap({required int openingBalanceMinor}) {
    return toWriteMap(openingBalanceMinor: openingBalanceMinor);
  }
}
