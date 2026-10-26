import '../../../core/finance/business_calendar.dart';
import '../../../core/money/money_formatter.dart';
import '../domain/report_document.dart';

class ReportMetric {
  const ReportMetric({required this.label, required this.value, this.caption});

  final String label;
  final String value;
  final String? caption;
}

/// Shared display strings for the in-app preview and the PDF.
abstract final class ReportCopy {
  static String money(ReportDocument report, int minor) {
    return MoneyFormatter.formatMinor(minor, currencyCode: report.currencyCode);
  }

  static String generatedOn(ReportDocument report) {
    final wall = BusinessCalendar.wallTime(report.generatedAt, _zone(report));
    final day = wall.day.toString().padLeft(2, '0');
    final month = _shortMonth(wall.month);
    final hour = wall.hour.toString().padLeft(2, '0');
    final minute = wall.minute.toString().padLeft(2, '0');
    return '$day $month ${wall.year}, $hour:$minute ${report.zoneName}';
  }

  static List<ReportMetric> financialMetrics(ReportDocument report) {
    return [
      ReportMetric(
        label: 'Recorded sales',
        value: money(report, report.recordedSalesMinor),
        caption: 'Confirmed sales in ${report.periodLabel}.',
      ),
      ReportMetric(
        label: 'Refunds',
        value: money(report, report.recordedRefundsMinor),
        caption: 'Customer refunds reduce net sales.',
      ),
      ReportMetric(
        label: 'Net sales after refunds',
        value: money(report, report.netRecordedSalesMinor),
      ),
      ReportMetric(
        label: 'Operating expenses',
        value: money(report, report.recordedOperatingExpensesMinor),
        caption: 'Paid and unpaid operating costs. Not owner withdrawals.',
      ),
      ReportMetric(
        label: 'Net operating result',
        value: money(report, report.netRecordedOperatingResultMinor),
        caption: 'Not audited profit or tax.',
      ),
      if (report.periodOpeningCashMinor != null)
        ReportMetric(
          label: 'Opening cash for the period',
          value: money(report, report.periodOpeningCashMinor!),
          caption:
              'Recorded cash immediately before ${report.periodLabel}. Opening cash is not revenue.',
        ),
      if (report.periodClosingCashMinor != null)
        ReportMetric(
          label: 'Recorded cash at period end',
          value: money(report, report.periodClosingCashMinor!),
          caption: 'Paid movements only. Unpaid sales are not included.',
        ),
      ReportMetric(
        label: 'Current recorded cash',
        value: money(report, report.currentRecordedCashMinor),
        caption:
            'All-time recorded cash as of the generation date, not bank-confirmed cash.',
      ),
    ];
  }

  static List<ReportMetric> counts(ReportDocument report) {
    return [
      ReportMetric(
        label: 'Confirmed transactions',
        value: '${report.confirmedInPeriodCount}',
      ),
      ReportMetric(label: 'Sales', value: '${report.saleCount}'),
      ReportMetric(label: 'Refunds', value: '${report.refundCount}'),
      ReportMetric(
        label: 'Operating expenses',
        value: '${report.expenseCount}',
      ),
      ReportMetric(
        label: 'Owner contributions',
        value: '${report.contributionCount}',
      ),
      ReportMetric(
        label: 'Owner withdrawals',
        value: '${report.withdrawalCount}',
      ),
    ];
  }

  static BusinessZone _zone(ReportDocument report) {
    return report.zoneName == BusinessZone.africaGaborone.name
        ? BusinessZone.africaGaborone
        : BusinessZone.africaGaborone;
  }

  static String _shortMonth(int month) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
