import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/business_calendar.dart';
import 'package:kgwebo/core/finance/dashboard_period.dart';

void main() {
  final now = DateTime.utc(2026, 10, 21, 12);
  const zone = BusinessZone.africaGaborone;

  test('this month resolves to October 2026 in Gaborone', () {
    final selected = DashboardPeriodSelection.resolve(
      kind: DashboardPeriodKind.thisMonth,
      nowUtc: now,
      zone: zone,
    );
    expect(selected.label, 'October 2026');
    expect(selected.period, BusinessCalendar.monthContaining(now, zone: zone));
  });

  test('last month resolves to September 2026', () {
    final selected = DashboardPeriodSelection.resolve(
      kind: DashboardPeriodKind.lastMonth,
      nowUtc: now,
      zone: zone,
    );
    expect(selected.label, 'September 2026');
    expect(selected.kind, DashboardPeriodKind.lastMonth);
  });

  test('last three months span August through October 2026', () {
    final selected = DashboardPeriodSelection.resolve(
      kind: DashboardPeriodKind.lastThreeMonths,
      nowUtc: now,
      zone: zone,
    );
    expect(selected.label, 'August – October 2026');
    expect(
      selected.period.startInclusive,
      BusinessCalendar.utcFromWall(zone: zone, year: 2026, month: 8, day: 1),
    );
  });

  test('this year uses the calendar year label', () {
    final selected = DashboardPeriodSelection.resolve(
      kind: DashboardPeriodKind.thisYear,
      nowUtc: now,
      zone: zone,
    );
    expect(selected.label, '2026');
  });

  test('custom range requires inclusive start and end dates', () {
    final selected = DashboardPeriodSelection.resolve(
      kind: DashboardPeriodKind.custom,
      nowUtc: now,
      zone: zone,
      customStartWall: DateTime(2026, 10, 1),
      customEndWall: DateTime(2026, 10, 7),
    );
    expect(selected.label, '1–7 Oct 2026');
    expect(selected.kind, DashboardPeriodKind.custom);
  });

  test('custom range falling back without dates uses this month', () {
    final selected = DashboardPeriodSelection.resolve(
      kind: DashboardPeriodKind.custom,
      nowUtc: now,
      zone: zone,
    );
    expect(selected.kind, DashboardPeriodKind.thisMonth);
    expect(selected.label, 'October 2026');
  });
}
