import '../../../core/finance/ledger_entry.dart';
import '../../../core/money/minor_units.dart';
import '../../../core/money/money_formatter.dart';
import 'financial_read_port.dart';

abstract class CopilotBookPort {
  Future<CopilotBook> currentBook();
}

class CopilotBillFact {
  const CopilotBillFact({
    required this.title,
    required this.amountMinor,
    required this.dueOn,
    required this.overdue,
  });

  final String title;
  final int amountMinor;
  final DateTime dueOn;
  final bool overdue;
}

class CopilotRecentFact {
  const CopilotRecentFact({
    required this.type,
    required this.amountMinor,
    required this.occurredAt,
    this.description,
  });

  final MoneyMovementType type;
  final int amountMinor;
  final DateTime occurredAt;
  final String? description;
}

class CopilotStockFact {
  const CopilotStockFact({
    required this.name,
    required this.sellingPriceMinor,
    required this.needsRestock,
  });

  final String name;
  final int sellingPriceMinor;
  final bool needsRestock;
}

class CopilotBook {
  const CopilotBook({
    this.snapshot,
    this.overdueBills = const [],
    this.upcomingBills = const [],
    this.recent = const [],
    this.products = const [],
  });

  final VerifiedFinancialSnapshot? snapshot;
  final List<CopilotBillFact> overdueBills;
  final List<CopilotBillFact> upcomingBills;
  final List<CopilotRecentFact> recent;
  final List<CopilotStockFact> products;

  String? matchProductName(String? item) {
    if (item == null || item.isEmpty) {
      return null;
    }
    final needle = item.toLowerCase();
    for (final product in products) {
      final name = product.name.toLowerCase();
      if (name == needle || name.contains(needle) || needle.contains(name)) {
        return product.name;
      }
    }
    return null;
  }
}

String billsReply(CopilotBook book) {
  final currency = book.snapshot?.currencyCode ?? 'BWP';
  final bills = [...book.overdueBills, ...book.upcomingBills];
  if (bills.isEmpty) {
    return 'There are no unpaid bills in recorded Kgwebo data right now.';
  }
  final buffer = StringBuffer(
    'These bills come from recorded Kgwebo data, not from the AI.\n',
  );
  for (final bill in bills.take(8)) {
    final amount = MoneyFormatter.formatMinor(
      bill.amountMinor,
      currencyCode: currency,
    );
    final due =
        '${bill.dueOn.year}-${bill.dueOn.month.toString().padLeft(2, '0')}-${bill.dueOn.day.toString().padLeft(2, '0')}';
    buffer.writeln(
      '${bill.overdue ? 'Overdue' : 'Upcoming'}: ${bill.title} $amount due $due.',
    );
  }
  return buffer.toString().trim();
}

String stockReply(CopilotBook book) {
  if (book.products.isEmpty) {
    return 'There is no recorded stock list yet. Add products on the Stock tab.';
  }
  final low = book.products.where((item) => item.needsRestock).toList();
  if (low.isEmpty) {
    return 'Recorded stock has ${book.products.length} products and none are marked for restock.';
  }
  final names = low.take(8).map((item) => item.name).join(', ');
  return 'Recorded stock that needs restocking: $names. This comes from Kgwebo, not from the AI.';
}

String recentReply(CopilotBook book) {
  if (book.recent.isEmpty) {
    return 'There are no recent recorded sales or expenses to open.';
  }
  final currency = book.snapshot?.currencyCode ?? 'BWP';
  final last = book.recent.first;
  final kind = switch (last.type) {
    MoneyMovementType.sale => 'sale',
    MoneyMovementType.expense => 'expense',
    MoneyMovementType.ownerWithdrawal => 'owner withdrawal',
    MoneyMovementType.ownerContribution => 'owner contribution',
    MoneyMovementType.refund => 'refund',
  };
  final amount = MoneyFormatter.formatMinor(
    last.amountMinor,
    currencyCode: currency,
  );
  final what =
      last.description == null || last.description!.isEmpty
          ? kind
          : last.description;
  return 'The most recent recorded $kind is $amount for $what. This comes from Kgwebo, not from the AI.';
}

/// Compact, non-cash facts the model may use. Never includes invented totals.
Map<String, Object?> bookDigest(CopilotBook book, {required bool includeCash}) {
  return {
    if (includeCash && book.snapshot != null)
      'snapshot': {
        'currencyCode': book.snapshot!.currencyCode,
        'recordedCashMinor': book.snapshot!.recordedCashMinor,
        'recordedSalesMinor': book.snapshot!.recordedSalesMinor,
        'recordedExpensesMinor': book.snapshot!.recordedExpensesMinor,
        'netOperatingResultMinor': book.snapshot!.netOperatingResultMinor,
        'periodLabel': book.snapshot!.periodLabel,
        'source': book.snapshot!.source,
      },
    'bills': [
      for (final bill in [...book.overdueBills, ...book.upcomingBills].take(8))
        {
          'title': bill.title,
          'amount': MinorUnits.format(bill.amountMinor, group: false),
          'overdue': bill.overdue,
        },
    ],
    'recent': [
      for (final item in book.recent.take(5))
        {
          'type': item.type.name,
          'amount': MinorUnits.format(item.amountMinor, group: false),
          'item': item.description,
        },
    ],
    'products': [
      for (final item in book.products.take(20)) {'name': item.name},
    ],
  };
}
