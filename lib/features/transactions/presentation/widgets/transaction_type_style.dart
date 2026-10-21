import 'package:flutter/material.dart';

import '../../../../app/theme/kgwebo_colors.dart';
import '../../../../core/finance/ledger_entry.dart';

abstract final class TransactionTypeStyle {
  static String label(MoneyMovementType type) {
    return switch (type) {
      MoneyMovementType.sale => 'Sale',
      MoneyMovementType.expense => 'Expense',
      MoneyMovementType.refund => 'Refund',
      MoneyMovementType.ownerContribution => 'Owner contribution',
      MoneyMovementType.ownerWithdrawal => 'Owner withdrawal',
    };
  }

  static IconData icon(MoneyMovementType type) {
    return switch (type) {
      MoneyMovementType.sale => Icons.south_west,
      MoneyMovementType.expense => Icons.north_east,
      MoneyMovementType.refund => Icons.replay,
      MoneyMovementType.ownerContribution => Icons.person_add_alt_1_outlined,
      MoneyMovementType.ownerWithdrawal => Icons.person_remove_outlined,
    };
  }

  static Color color(MoneyMovementType type) {
    return switch (type) {
      MoneyMovementType.sale => KgweboColors.success,
      MoneyMovementType.expense => KgweboColors.danger,
      MoneyMovementType.refund => KgweboColors.warning,
      MoneyMovementType.ownerContribution => KgweboColors.ink,
      MoneyMovementType.ownerWithdrawal => KgweboColors.inkMuted,
    };
  }

  static bool isInflow(MoneyMovementType type) {
    return switch (type) {
      MoneyMovementType.sale || MoneyMovementType.ownerContribution => true,
      MoneyMovementType.expense ||
      MoneyMovementType.refund ||
      MoneyMovementType.ownerWithdrawal => false,
    };
  }
}
