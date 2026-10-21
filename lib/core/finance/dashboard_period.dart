import 'business_calendar.dart';

enum DashboardPeriodKind {
  thisMonth,
  lastMonth,
  lastThreeMonths,
  thisYear,
  custom,
}

class DashboardPeriodSelection {
  const DashboardPeriodSelection({
    required this.kind,
    required this.period,
    required this.label,
    required this.zone,
  });

  final DashboardPeriodKind kind;
  final ReportingPeriod period;
  final String label;
  final BusinessZone zone;

  String get chipLabel {
    return switch (kind) {
      DashboardPeriodKind.thisMonth => 'This month',
      DashboardPeriodKind.lastMonth => 'Last month',
      DashboardPeriodKind.lastThreeMonths => 'Last 3 months',
      DashboardPeriodKind.thisYear => 'This year',
      DashboardPeriodKind.custom => 'Custom',
    };
  }

  factory DashboardPeriodSelection.resolve({
    required DashboardPeriodKind kind,
    required DateTime nowUtc,
    BusinessZone zone = BusinessZone.africaGaborone,
    DateTime? customStartWall,
    DateTime? customEndWall,
  }) {
    switch (kind) {
      case DashboardPeriodKind.thisMonth:
        final period = BusinessCalendar.monthContaining(nowUtc, zone: zone);
        return DashboardPeriodSelection(
          kind: kind,
          period: period,
          label: BusinessCalendar.monthLabel(period, zone: zone),
          zone: zone,
        );
      case DashboardPeriodKind.lastMonth:
        final period = BusinessCalendar.previousMonth(nowUtc, zone: zone);
        return DashboardPeriodSelection(
          kind: kind,
          period: period,
          label: BusinessCalendar.monthLabel(period, zone: zone),
          zone: zone,
        );
      case DashboardPeriodKind.lastThreeMonths:
        final period = BusinessCalendar.trailingMonths(
          nowUtc,
          monthCount: 3,
          zone: zone,
        );
        return DashboardPeriodSelection(
          kind: kind,
          period: period,
          label: BusinessCalendar.rangeLabel(period, zone: zone),
          zone: zone,
        );
      case DashboardPeriodKind.thisYear:
        final period = BusinessCalendar.yearContaining(nowUtc, zone: zone);
        return DashboardPeriodSelection(
          kind: kind,
          period: period,
          label: BusinessCalendar.rangeLabel(period, zone: zone),
          zone: zone,
        );
      case DashboardPeriodKind.custom:
        if (customStartWall == null || customEndWall == null) {
          return DashboardPeriodSelection.resolve(
            kind: DashboardPeriodKind.thisMonth,
            nowUtc: nowUtc,
            zone: zone,
          );
        }
        final period = BusinessCalendar.inclusiveDays(
          startWall: customStartWall,
          endWall: customEndWall,
          zone: zone,
        );
        return DashboardPeriodSelection(
          kind: kind,
          period: period,
          label: BusinessCalendar.rangeLabel(period, zone: zone),
          zone: zone,
        );
    }
  }
}
