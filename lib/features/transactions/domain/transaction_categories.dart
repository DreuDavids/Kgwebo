import '../../../core/finance/ledger_entry.dart';
import '../../onboarding/domain/onboarding_options.dart';

abstract final class TransactionCategories {
  static const sale = [
    LabeledCode('goods', 'Goods sold'),
    LabeledCode('services', 'Services'),
    LabeledCode('other_sale', 'Other sale'),
  ];

  static const expense = [
    LabeledCode('stock', 'Stock and supplies'),
    LabeledCode('rent', 'Rent'),
    LabeledCode('transport', 'Transport'),
    LabeledCode('utilities', 'Utilities'),
    LabeledCode('wages', 'Wages'),
    LabeledCode('fees', 'Fees and charges'),
    LabeledCode('other_expense', 'Other operating expense'),
  ];

  static const refund = [LabeledCode('customer_refund', 'Customer refund')];

  static const ownerContribution = [
    LabeledCode('owner_contribution', 'Owner contribution'),
  ];

  static const ownerWithdrawal = [
    LabeledCode('owner_withdrawal', 'Owner withdrawal'),
  ];

  static List<LabeledCode> forType(MoneyMovementType type) {
    return switch (type) {
      MoneyMovementType.sale => sale,
      MoneyMovementType.expense => expense,
      MoneyMovementType.refund => refund,
      MoneyMovementType.ownerContribution => ownerContribution,
      MoneyMovementType.ownerWithdrawal => ownerWithdrawal,
    };
  }

  static String labelFor(MoneyMovementType type, String code) {
    for (final item in forType(type)) {
      if (item.code == code) {
        return item.label;
      }
    }
    return code;
  }

  static bool isAllowed(MoneyMovementType type, String code) {
    return forType(type).any((item) => item.code == code);
  }

  static String defaultCode(MoneyMovementType type) {
    return forType(type).first.code;
  }
}
