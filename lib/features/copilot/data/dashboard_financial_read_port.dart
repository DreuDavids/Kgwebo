import '../../dashboard/application/dashboard_finance_controller.dart';
import '../application/financial_read_port.dart';

class DashboardFinancialReadPort implements FinancialReadPort {
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
}
