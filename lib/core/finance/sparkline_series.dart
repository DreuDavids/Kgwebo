import 'business_calendar.dart';
import 'ledger_entry.dart';

/// One Gaborone day's recorded total. Empty series means there is nothing
/// real to plot — never a fake flat line.
class DailyBucket {
  const DailyBucket({required this.startUtc, required this.amountMinor});

  final DateTime startUtc;
  final int amountMinor;
}

/// Daily totals used by dashboard charts. Empty when there is nothing real
/// to plot.
abstract final class SparklineSeries {
  /// One point per Gaborone day from [period.startInclusive] through [asOf].
  /// Returns an empty list when every bucket is zero so charts stay honest.
  static List<DailyBucket> dailyBuckets({
    required Iterable<LedgerEntry> entries,
    required ReportingPeriod period,
    required DateTime asOf,
    required Set<MoneyMovementType> types,
  }) {
    final start = period.startInclusive.toUtc();
    final lastExclusive =
        period.endExclusive.toUtc().isBefore(
              BusinessCalendar.exclusiveEndOfGaboroneDay(asOf),
            )
            ? period.endExclusive.toUtc()
            : BusinessCalendar.exclusiveEndOfGaboroneDay(asOf);
    if (!lastExclusive.isAfter(start)) {
      return const [];
    }

    final dayCount = lastExclusive.difference(start).inDays;
    if (dayCount <= 0) {
      return const [];
    }

    final amounts = List<int>.filled(dayCount, 0);
    var hasValue = false;
    for (final entry in entries) {
      if (!types.contains(entry.type) || !period.contains(entry.occurredAt)) {
        continue;
      }
      final index = entry.occurredAt.toUtc().difference(start).inDays;
      if (index < 0 || index >= dayCount) {
        continue;
      }
      amounts[index] += entry.amountMinor;
      if (entry.amountMinor != 0) {
        hasValue = true;
      }
    }
    if (!hasValue) {
      return const [];
    }
    return [
      for (var i = 0; i < dayCount; i++)
        DailyBucket(
          startUtc: start.add(Duration(days: i)),
          amountMinor: amounts[i],
        ),
    ];
  }

  /// One point per Gaborone day from [period.startInclusive] through [asOf].
  /// Returns an empty list when every bucket is zero so charts stay honest.
  static List<double> dailyTotals({
    required Iterable<LedgerEntry> entries,
    required ReportingPeriod period,
    required DateTime asOf,
    required Set<MoneyMovementType> types,
  }) {
    return [
      for (final bucket in dailyBuckets(
        entries: entries,
        period: period,
        asOf: asOf,
        types: types,
      ))
        bucket.amountMinor.toDouble(),
    ];
  }
}
