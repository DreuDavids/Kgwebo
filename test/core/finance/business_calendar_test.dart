import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/business_calendar.dart';

void main() {
  const zone = BusinessZone.africaGaborone;
  // 12:00 UTC on 21 Oct 2026 is 14:00 in Gaborone.
  final now = DateTime.utc(2026, 10, 21, 12);

  test(
    'Botswana uses Africa/Gaborone and unknown countries fall back to it',
    () {
      expect(BusinessZone.forCountry('BW').name, 'Africa/Gaborone');
      expect(BusinessZone.forCountry('bw').utcOffset, const Duration(hours: 2));
      expect(BusinessZone.forCountry('ZZ').name, 'Africa/Gaborone');
    },
  );

  test('this month is the Gaborone calendar month containing as-of', () {
    final period = BusinessCalendar.monthContaining(now, zone: zone);
    expect(
      period.startInclusive,
      BusinessCalendar.utcFromWall(zone: zone, year: 2026, month: 10, day: 1),
    );
    expect(
      period.endExclusive,
      BusinessCalendar.utcFromWall(zone: zone, year: 2026, month: 11, day: 1),
    );
    expect(BusinessCalendar.gaboroneMonthContaining(now), period);
  });

  test('last month is the previous complete Gaborone calendar month', () {
    final period = BusinessCalendar.previousMonth(now, zone: zone);
    expect(
      period.startInclusive,
      BusinessCalendar.utcFromWall(zone: zone, year: 2026, month: 9, day: 1),
    );
    expect(
      period.endExclusive,
      BusinessCalendar.utcFromWall(zone: zone, year: 2026, month: 10, day: 1),
    );
  });

  test('last three months start at the first of the month two months back', () {
    final period = BusinessCalendar.trailingMonths(
      now,
      monthCount: 3,
      zone: zone,
    );
    expect(
      period.startInclusive,
      BusinessCalendar.utcFromWall(zone: zone, year: 2026, month: 8, day: 1),
    );
    expect(
      period.endExclusive,
      BusinessCalendar.utcFromWall(zone: zone, year: 2026, month: 11, day: 1),
    );
  });

  test('this year is the Gaborone calendar year containing as-of', () {
    final period = BusinessCalendar.yearContaining(now, zone: zone);
    expect(
      period.startInclusive,
      BusinessCalendar.utcFromWall(zone: zone, year: 2026, month: 1, day: 1),
    );
    expect(
      period.endExclusive,
      BusinessCalendar.utcFromWall(zone: zone, year: 2027, month: 1, day: 1),
    );
  });

  test('custom inclusive days use exclusive end of the last Gaborone day', () {
    final period = BusinessCalendar.inclusiveDays(
      startWall: DateTime(2026, 10, 12),
      endWall: DateTime(2026, 10, 21),
      zone: zone,
    );
    expect(
      period.startInclusive,
      BusinessCalendar.utcFromWall(zone: zone, year: 2026, month: 10, day: 12),
    );
    expect(
      period.endExclusive,
      BusinessCalendar.utcFromWall(zone: zone, year: 2026, month: 10, day: 22),
    );
    expect(period.contains(period.startInclusive), isTrue);
    expect(
      period.contains(
        period.endExclusive.subtract(const Duration(microseconds: 1)),
      ),
      isTrue,
    );
    expect(period.contains(period.endExclusive), isFalse);
  });

  test('January previous month and year boundary stay exclusive', () {
    final january = DateTime.utc(2027, 1, 5, 10);
    final lastMonth = BusinessCalendar.previousMonth(january, zone: zone);
    expect(
      lastMonth.startInclusive,
      BusinessCalendar.utcFromWall(zone: zone, year: 2026, month: 12, day: 1),
    );
    expect(
      lastMonth.endExclusive,
      BusinessCalendar.utcFromWall(zone: zone, year: 2027, month: 1, day: 1),
    );
  });

  test('gaborone helpers remain the Africa/Gaborone convenience wrappers', () {
    expect(
      BusinessCalendar.utcFromGaborone(year: 2026, month: 10, day: 1),
      BusinessCalendar.utcFromWall(zone: zone, year: 2026, month: 10, day: 1),
    );
  });
}
