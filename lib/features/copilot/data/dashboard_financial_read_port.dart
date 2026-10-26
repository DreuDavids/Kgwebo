import '../../../core/inventory/inventory_insights.dart';
import '../../dashboard/application/dashboard_finance_controller.dart';
import '../application/copilot_book.dart';
import '../application/financial_read_port.dart';

class DashboardFinancialReadPort implements FinancialReadPort, CopilotBookPort {
  const DashboardFinancialReadPort(this._state);

  final DashboardFinanceState _state;

  @override
  Future<VerifiedFinancialSnapshot?> currentSnapshot() async {
    final summary = _state.summary;
    if (summary == null) {
      return null;
    }
    return VerifiedFinancialSnapshot(
      currencyCode: summary.currencyCode,
      recordedCashMinor: summary.currentCashMinor,
      recordedSalesMinor: summary.recordedSalesMinor,
      recordedExpensesMinor: summary.recordedOperatingExpensesMinor,
      netOperatingResultMinor: summary.netRecordedOperatingResultMinor,
      periodLabel:
          _state.periodLabel.isEmpty
              ? 'the selected period'
              : _state.periodLabel,
      source: 'FinancialEngine',
    );
  }

  @override
  Future<CopilotBook> currentBook() async {
    final snapshot = await currentSnapshot();
    final insights = InventoryInsights.fromProducts(_state.products);
    return CopilotBook(
      snapshot: snapshot,
      overdueBills: [
        for (final bill in _state.overdue)
          CopilotBillFact(
            title: bill.title,
            amountMinor: bill.amountMinor,
            dueOn: bill.dueOn,
            overdue: true,
          ),
      ],
      upcomingBills: [
        for (final bill in _state.upcoming)
          CopilotBillFact(
            title: bill.title,
            amountMinor: bill.amountMinor,
            dueOn: bill.dueOn,
            overdue: false,
          ),
      ],
      recent: [
        for (final item in _state.recent)
          CopilotRecentFact(
            type: item.type,
            amountMinor: item.amountMinor,
            occurredAt: item.occurredAt,
            description: item.description,
          ),
      ],
      products: [
        for (final item in _state.products)
          CopilotStockFact(
            name: item.name,
            sellingPriceMinor: item.sellingPriceMinor,
            needsRestock: insights.restockProductIds.contains(item.id),
          ),
      ],
    );
  }
}
