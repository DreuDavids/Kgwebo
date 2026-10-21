import 'business_calendar.dart';
import 'ledger_entry.dart';

/// Daily totals used by sparklines. Empty when there is nothing real to plot.
abstract final class SparklineSeries {
  /// One point per Gaborone day from [period.startInclusive] through [asOf].
  /// Returns an empty list when every bucket is zero so charts stay honest.
  static List<double> dailyTotals({
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

    final buckets = List<double>.filled(dayCount, 0);
    var hasValue = false;
    for (final entry in entries) {
      if (!types.contains(entry.type) || !period.contains(entry.occurredAt)) {
        continue;
      }
      final index = entry.occurredAt.toUtc().difference(start).inDays;
      if (index < 0 || index >= dayCount) {
        continue;
      }
      buckets[index] += entry.amountMinor.toDouble();
      if (entry.amountMinor != 0) {
        hasValue = true;
      }
    }
    return hasValue ? buckets : const [];
  }
}
