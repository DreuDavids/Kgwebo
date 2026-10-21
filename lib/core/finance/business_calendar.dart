/// Business calendar helpers keyed by a named offset zone.
///
/// Botswana does not observe daylight-saving time. Africa/Gaborone is UTC+2
/// year-round, so these conversions do not consult a tz database. Other
/// countries currently fall back to Gaborone until regional zones ship.
class BusinessZone {
  const BusinessZone({required this.name, required this.utcOffset});

  final String name;
  final Duration utcOffset;

  static const africaGaborone = BusinessZone(
    name: 'Africa/Gaborone',
    utcOffset: Duration(hours: 2),
  );

  /// Resolves the reporting zone for a stored ISO country code.
  /// Unknown codes fall back to Africa/Gaborone rather than guessing DST.
  static BusinessZone forCountry(String countryCode) {
    switch (countryCode.trim().toUpperCase()) {
      case 'BW':
        return africaGaborone;
      default:
        return africaGaborone;
    }
  }
}

/// Calendar helpers for dashboard periods and transaction dates.
abstract final class BusinessCalendar {
  static const timeZoneName = 'Africa/Gaborone';
  static const offset = Duration(hours: 2);

  static DateTime utcFromWall({
    required BusinessZone zone,
    required int year,
    required int month,
    required int day,
    int hour = 0,
    int minute = 0,
    int second = 0,
    int millisecond = 0,
  }) {
    return DateTime.utc(
      year,
      month,
      day,
      hour,
      minute,
      second,
      millisecond,
    ).subtract(zone.utcOffset);
  }

  static DateTime utcFromGaborone({
    required int year,
    required int month,
    required int day,
    int hour = 0,
    int minute = 0,
    int second = 0,
    int millisecond = 0,
  }) {
    return utcFromWall(
      zone: BusinessZone.africaGaborone,
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
      second: second,
      millisecond: millisecond,
    );
  }

  static DateTime wallTime(DateTime utc, BusinessZone zone) {
    return utc.toUtc().add(zone.utcOffset);
  }

  static DateTime gaboroneWallTime(DateTime utc) {
    return wallTime(utc, BusinessZone.africaGaborone);
  }

  static DateTime startOfDay(
    DateTime utc, {
    BusinessZone zone = BusinessZone.africaGaborone,
  }) {
    final wall = wallTime(utc, zone);
    return utcFromWall(
      zone: zone,
      year: wall.year,
      month: wall.month,
      day: wall.day,
    );
  }

  static DateTime startOfGaboroneDay(DateTime utc) {
    return startOfDay(utc);
  }

  static DateTime exclusiveEndOfDay(
    DateTime utc, {
    BusinessZone zone = BusinessZone.africaGaborone,
  }) {
    final wall = wallTime(utc, zone);
    return utcFromWall(
      zone: zone,
      year: wall.year,
      month: wall.month,
      day: wall.day + 1,
    );
  }

  static DateTime exclusiveEndOfGaboroneDay(DateTime utc) {
    return exclusiveEndOfDay(utc);
  }

  static ReportingPeriod gaboroneDay(DateTime utc) {
    return ReportingPeriod(
      startInclusive: startOfGaboroneDay(utc),
      endExclusive: exclusiveEndOfGaboroneDay(utc),
    );
  }

  static ReportingPeriod monthContaining(
    DateTime utc, {
    BusinessZone zone = BusinessZone.africaGaborone,
  }) {
    final wall = wallTime(utc, zone);
    final start = utcFromWall(
      zone: zone,
      year: wall.year,
      month: wall.month,
      day: 1,
    );
    final end = utcFromWall(
      zone: zone,
      year: wall.year,
      month: wall.month + 1,
      day: 1,
    );
    return ReportingPeriod(startInclusive: start, endExclusive: end);
  }

  static ReportingPeriod gaboroneMonthContaining(DateTime utc) {
    return monthContaining(utc);
  }

  static ReportingPeriod previousMonth(
    DateTime utc, {
    BusinessZone zone = BusinessZone.africaGaborone,
  }) {
    final wall = wallTime(utc, zone);
    final start = utcFromWall(
      zone: zone,
      year: wall.year,
      month: wall.month - 1,
      day: 1,
    );
    final end = utcFromWall(
      zone: zone,
      year: wall.year,
      month: wall.month,
      day: 1,
    );
    return ReportingPeriod(startInclusive: start, endExclusive: end);
  }

  static ReportingPeriod trailingMonths(
    DateTime utc, {
    required int monthCount,
    BusinessZone zone = BusinessZone.africaGaborone,
  }) {
    final wall = wallTime(utc, zone);
    final start = utcFromWall(
      zone: zone,
      year: wall.year,
      month: wall.month - (monthCount - 1),
      day: 1,
    );
    final end = utcFromWall(
      zone: zone,
      year: wall.year,
      month: wall.month + 1,
      day: 1,
    );
    return ReportingPeriod(startInclusive: start, endExclusive: end);
  }

  static ReportingPeriod yearContaining(
    DateTime utc, {
    BusinessZone zone = BusinessZone.africaGaborone,
  }) {
    final wall = wallTime(utc, zone);
    final start = utcFromWall(zone: zone, year: wall.year, month: 1, day: 1);
    final end = utcFromWall(zone: zone, year: wall.year + 1, month: 1, day: 1);
    return ReportingPeriod(startInclusive: start, endExclusive: end);
  }

  static ReportingPeriod inclusiveDays({
    required DateTime startWall,
    required DateTime endWall,
    BusinessZone zone = BusinessZone.africaGaborone,
  }) {
    var start = DateTime(startWall.year, startWall.month, startWall.day);
    var end = DateTime(endWall.year, endWall.month, endWall.day);
    if (end.isBefore(start)) {
      final swap = start;
      start = end;
      end = swap;
    }
    return ReportingPeriod(
      startInclusive: utcFromWall(
        zone: zone,
        year: start.year,
        month: start.month,
        day: start.day,
      ),
      endExclusive: utcFromWall(
        zone: zone,
        year: end.year,
        month: end.month,
        day: end.day + 1,
      ),
    );
  }

  static String monthLabel(
    ReportingPeriod period, {
    BusinessZone zone = BusinessZone.africaGaborone,
  }) {
    final wall = wallTime(period.startInclusive, zone);
    return '${_monthName(wall.month)} ${wall.year}';
  }

  static String rangeLabel(
    ReportingPeriod period, {
    BusinessZone zone = BusinessZone.africaGaborone,
  }) {
    final start = wallTime(period.startInclusive, zone);
    final endExclusiveWall = wallTime(
      period.endExclusive.subtract(const Duration(microseconds: 1)),
      zone,
    );
    if (start.year == endExclusiveWall.year &&
        start.month == endExclusiveWall.month &&
        start.day == 1 &&
        endExclusiveWall.day >= 28) {
      return monthLabel(period, zone: zone);
    }
    if (start.month == 1 &&
        start.day == 1 &&
        endExclusiveWall.month == 12 &&
        start.year == endExclusiveWall.year) {
      return '${start.year}';
    }
    if (start.year == endExclusiveWall.year &&
        start.month != endExclusiveWall.month &&
        start.day == 1) {
      return '${_monthName(start.month)} – ${_monthName(endExclusiveWall.month)} ${start.year}';
    }
    if (start.year == endExclusiveWall.year &&
        start.month == endExclusiveWall.month) {
      return '${start.day}–${endExclusiveWall.day} ${_shortMonth(start.month)} ${start.year}';
    }
    return '${start.day} ${_shortMonth(start.month)} ${start.year} – ${endExclusiveWall.day} ${_shortMonth(endExclusiveWall.month)} ${endExclusiveWall.year}';
  }

  static String _monthName(int month) {
    const months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
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

class ReportingPeriod {
  const ReportingPeriod({
    required this.startInclusive,
    required this.endExclusive,
  });

  final DateTime startInclusive;
  final DateTime endExclusive;

  bool contains(DateTime utc) {
    final instant = utc.toUtc();
    return !instant.isBefore(startInclusive.toUtc()) &&
        instant.isBefore(endExclusive.toUtc());
  }

  @override
  bool operator ==(Object other) {
    return other is ReportingPeriod &&
        other.startInclusive.toUtc() == startInclusive.toUtc() &&
        other.endExclusive.toUtc() == endExclusive.toUtc();
  }

  @override
  int get hashCode => Object.hash(startInclusive.toUtc(), endExclusive.toUtc());
}
