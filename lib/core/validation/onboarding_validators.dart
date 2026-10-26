import '../../features/onboarding/domain/onboarding_draft.dart';
import '../money/money_parser.dart';

class OnboardingFieldErrors {
  const OnboardingFieldErrors({
    this.name,
    this.businessType,
    this.countryCode,
    this.currencyCode,
    this.openingCash,
  });

  final String? name;
  final String? businessType;
  final String? countryCode;
  final String? currencyCode;
  final String? openingCash;

  bool get hasErrors =>
      name != null ||
      businessType != null ||
      countryCode != null ||
      currencyCode != null ||
      openingCash != null;
}

OnboardingFieldErrors validateOnboardingDraft(OnboardingDraft draft) {
  String? openingCashError;
  final parsed = tryParseOpeningBalanceMinor(draft.openingCashText);
  if (parsed == null) {
    openingCashError = 'Enter a valid amount, or leave this blank for zero.';
  }

  return OnboardingFieldErrors(
    name: draft.name.trim().isEmpty ? 'Enter your business name.' : null,
    businessType:
        draft.businessType.trim().isEmpty ? 'Choose a business type.' : null,
    countryCode:
        draft.countryCode.trim().length == 2 ? null : 'Choose a country.',
    currencyCode:
        draft.currencyCode.trim().length == 3 ? null : 'Choose a currency.',
    openingCash: openingCashError,
  );
}

int parseOpeningBalanceMinor(String raw) {
  final parsed = tryParseOpeningBalanceMinor(raw);
  if (parsed == null) {
    throw FormatException('Invalid opening cash', raw);
  }
  return parsed;
}

int? tryParseOpeningBalanceMinor(String raw) {
  final text = raw.trim();
  if (text.isEmpty) {
    return 0;
  }
  return tryParseMinorUnits(text, allowZero: true);
}
