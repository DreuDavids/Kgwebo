import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/ledger_entry.dart';
import 'package:kgwebo/features/copilot/application/copilot_book.dart';
import 'package:kgwebo/features/copilot/application/financial_read_port.dart';

void main() {
  const snapshot = VerifiedFinancialSnapshot(
    currencyCode: 'BWP',
    recordedCashMinor: 255000,
    recordedSalesMinor: 50000,
    recordedExpensesMinor: 10000,
    netOperatingResultMinor: 40000,
    periodLabel: 'October 2026',
    source: 'FinancialEngine',
  );

  test('explains unpaid bills from recorded Kgwebo data', () {
    final book = CopilotBook(
      snapshot: snapshot,
      overdueBills: [
        CopilotBillFact(
          title: 'Shop rent',
          amountMinor: 80000,
          dueOn: DateTime(2026, 10, 1),
          overdue: true,
        ),
      ],
    );

    final reply = billsReply(book);
    expect(reply.toLowerCase(), contains('shop rent'));
    expect(reply.toLowerCase(), contains('overdue'));
    expect(reply, isNot(contains('9,999')));
  });

  test('names recorded stock that needs restocking', () {
    const book = CopilotBook(
      snapshot: snapshot,
      products: [
        CopilotStockFact(
          name: 'Fat cakes',
          sellingPriceMinor: 1000,
          needsRestock: true,
        ),
      ],
    );

    expect(stockReply(book), contains('Fat cakes'));
    expect(book.matchProductName('fat cakes'), 'Fat cakes');
  });

  test('restates the most recent recorded sale', () {
    final book = CopilotBook(
      snapshot: snapshot,
      recent: [
        CopilotRecentFact(
          type: MoneyMovementType.sale,
          amountMinor: 30000,
          occurredAt: DateTime(2026, 10, 21),
          description: 'shirts',
        ),
      ],
    );

    expect(recentReply(book).toLowerCase(), contains('shirts'));
    expect(recentReply(book), contains('300.00'));
  });
}
