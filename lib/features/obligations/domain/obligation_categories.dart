import '../../onboarding/domain/onboarding_options.dart';

abstract final class ObligationCategories {
  static const all = [
    LabeledCode('rent', 'Rent'),
    LabeledCode('supplier', 'Supplier payment'),
    LabeledCode('loan', 'Loan repayment'),
    LabeledCode('utilities', 'Utilities'),
    LabeledCode('wages', 'Wages'),
    LabeledCode('other', 'Other commitment'),
  ];

  static String defaultCode() => all.first.code;

  static String labelFor(String code) {
    for (final item in all) {
      if (item.code == code) {
        return item.label;
      }
    }
    return code;
  }

  static bool isAllowed(String code) {
    return all.any((item) => item.code == code);
  }
}
