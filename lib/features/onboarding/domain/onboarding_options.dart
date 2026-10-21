class LabeledCode {
  const LabeledCode(this.code, this.label);

  final String code;
  final String label;
}

abstract final class OnboardingOptions {
  static const businessTypes = [
    'Informal trader',
    'Retail shop',
    'Market stall',
    'Food and drink',
    'Services',
    'Agriculture',
    'Other',
  ];

  static const countries = [
    LabeledCode('BW', 'Botswana'),
    LabeledCode('ZA', 'South Africa'),
    LabeledCode('NA', 'Namibia'),
    LabeledCode('ZW', 'Zimbabwe'),
  ];

  static const currencies = [
    LabeledCode('BWP', 'Pula (BWP)'),
    LabeledCode('ZAR', 'Rand (ZAR)'),
    LabeledCode('NAD', 'Namibia dollar (NAD)'),
    LabeledCode('USD', 'US dollar (USD)'),
  ];

  static String countryLabel(String code) {
    for (final country in countries) {
      if (country.code == code) {
        return country.label;
      }
    }
    return code;
  }

  static String currencyLabel(String code) {
    for (final currency in currencies) {
      if (currency.code == code) {
        return currency.label;
      }
    }
    return code;
  }
}
