import '../money/money_limits.dart';
import 'business_calendar.dart';
import 'cash_outlook.dart';
import 'finance_exception.dart';

/// Inclusive calendar-day windows in the business zone.
enum ForecastHorizon {
  days7(7, '7 days'),
  days14(14, '14 days'),
  days30(30, '30 days');

  const ForecastHorizon(this.dayCount, this.label);

  final int dayCount;
  final String label;
}

class ForecastDay {
  const ForecastDay({
    required this.wallDate,
    required this.projectedCashMinor,
    required this.outflowMinor,
    required this.commitmentIds,
  });

  /// Date-only wall calendar day in the business zone.
  final DateTime wallDate;
  final int projectedCashMinor;
  final int outflowMinor;
  final List<String> commitmentIds;
}

class ForecastLimitation {
  const ForecastLimitation({required this.code, required this.message});

  final String code;
  final String message;
}

/// Deterministic short-term cash outlook. Never invents future sales.
class CashForecast {
  const CashForecast({
    required this.horizon,
    required this.currencyCode,
    required this.zone,
    required this.asOfDate,
    required this.horizonEndDate,
    required this.currentCashMinor,
    required this.expectedIncomingMinor,
    required this.overdueMinor,
    required this.upcomingWithinHorizonMinor,
    required this.upcomingAfterHorizonMinor,
    required this.estimatedCashAfterKnownCommitmentsMinor,
    required this.daily,
    required this.assumptions,
    required this.limitations,
    required this.countedCommitments,
    required this.skippedMixedCurrency,
    this.firstInsufficientOn,
  });

  final ForecastHorizon horizon;
  final String currencyCode;
  final BusinessZone zone;
  final DateTime asOfDate;
  final DateTime horizonEndDate;
  final int currentCashMinor;
  final int expectedIncomingMinor;
  final int overdueMinor;
  final int upcomingWithinHorizonMinor;
  final int upcomingAfterHorizonMinor;
  final int estimatedCashAfterKnownCommitmentsMinor;
  final DateTime? firstInsufficientOn;
  final List<ForecastDay> daily;
  final List<String> assumptions;
  final List<ForecastLimitation> limitations;
  final int countedCommitments;
  final int skippedMixedCurrency;

  bool get incomingForecastAvailable => expectedIncomingMinor != 0;

  bool get hasKnownOutflows =>
      overdueMinor > 0 || upcomingWithinHorizonMinor > 0;

  bool get hasProjectedPath => daily.any((day) => day.outflowMinor != 0);
}

abstract final class CashForecastEngine {
  static const incomingNotForecast = 'incoming_not_forecast';
  static const unpaidExpensesNotDated = 'unpaid_expenses_not_dated';
  static const inventoryNotCash = 'inventory_not_cash';
  static const incompleteHistory = 'incomplete_history';
  static const mixedCurrency = 'mixed_currency';
  static const commitmentsBeyondHorizon = 'commitments_beyond_horizon';

  static CashForecast project({
    required int currentCashMinor,
    required String currencyCode,
    required Iterable<ScheduledCommitment> commitments,
    required DateTime asOf,
    required ForecastHorizon horizon,
    BusinessZone zone = BusinessZone.africaGaborone,
    int unpaidSalesMinor = 0,
    int unpaidExpensesMinor = 0,
    int inventoryValueMinor = 0,
    bool hitRecordCap = false,
    int skippedMixedCurrencyTransactions = 0,
  }) {
    if (currencyCode.trim().length != 3) {
      throw const FinanceException('A three-letter currency code is required.');
    }

    final asOfWall = BusinessCalendar.wallTime(asOf, zone);
    final asOfDate = DateTime(asOfWall.year, asOfWall.month, asOfWall.day);
    final horizonEndDate = DateTime(
      asOfDate.year,
      asOfDate.month,
      asOfDate.day + (horizon.dayCount - 1),
    );
    final seenIds = <String>{};
    var overdue = 0;
    var upcomingWithin = 0;
    var upcomingAfter = 0;
    var counted = 0;
    var skippedMixed = 0;
    final overdueIds = <String>[];
    final byDay = <DateTime, _DayBucket>{};

    for (final commitment in commitments) {
      if (commitment.id.isEmpty) {
        throw const FinanceException('Every commitment needs a stable id.');
      }
      if (!seenIds.add(commitment.id)) {
        continue;
      }
      if (commitment.currencyCode != currencyCode) {
        skippedMixed += 1;
        continue;
      }
      if (commitment.status != CommitmentStatus.unpaid) {
        counted += 1;
        continue;
      }
      _validateAmount(commitment.amountMinor);
      counted += 1;
      final due = DateTime(
        commitment.dueOn.year,
        commitment.dueOn.month,
        commitment.dueOn.day,
      );
      if (due.isBefore(asOfDate)) {
        overdue = _add(overdue, commitment.amountMinor);
        overdueIds.add(commitment.id);
      } else if (!due.isAfter(horizonEndDate)) {
        upcomingWithin = _add(upcomingWithin, commitment.amountMinor);
        final bucket = byDay.putIfAbsent(due, _DayBucket.new);
        bucket.outflowMinor = _add(bucket.outflowMinor, commitment.amountMinor);
        bucket.ids.add(commitment.id);
      } else {
        upcomingAfter = _add(upcomingAfter, commitment.amountMinor);
      }
    }

    final knownOutflows = _add(overdue, upcomingWithin);
    final estimated = _add(currentCashMinor, -knownOutflows);
    final daily = <ForecastDay>[];
    var running = currentCashMinor;
    DateTime? firstInsufficientOn;

    for (var offset = 0; offset < horizon.dayCount; offset += 1) {
      final wallDate = DateTime(
        asOfDate.year,
        asOfDate.month,
        asOfDate.day + offset,
      );
      var outflow = 0;
      final ids = <String>[];
      if (offset == 0 && overdue > 0) {
        outflow = _add(outflow, overdue);
        ids.addAll(overdueIds);
      }
      final dueToday = byDay[wallDate];
      if (dueToday != null) {
        outflow = _add(outflow, dueToday.outflowMinor);
        ids.addAll(dueToday.ids);
      }
      running = _add(running, -outflow);
      if (firstInsufficientOn == null && running < 0) {
        firstInsufficientOn = wallDate;
      }
      daily.add(
        ForecastDay(
          wallDate: wallDate,
          projectedCashMinor: running,
          outflowMinor: outflow,
          commitmentIds: List<String>.unmodifiable(ids),
        ),
      );
    }

    return CashForecast(
      horizon: horizon,
      currencyCode: currencyCode,
      zone: zone,
      asOfDate: asOfDate,
      horizonEndDate: horizonEndDate,
      currentCashMinor: currentCashMinor,
      expectedIncomingMinor: 0,
      overdueMinor: overdue,
      upcomingWithinHorizonMinor: upcomingWithin,
      upcomingAfterHorizonMinor: upcomingAfter,
      estimatedCashAfterKnownCommitmentsMinor: estimated,
      firstInsufficientOn: firstInsufficientOn,
      daily: List<ForecastDay>.unmodifiable(daily),
      assumptions: _assumptions(horizon: horizon, zone: zone),
      limitations: _limitations(
        unpaidSalesMinor: unpaidSalesMinor,
        unpaidExpensesMinor: unpaidExpensesMinor,
        inventoryValueMinor: inventoryValueMinor,
        hitRecordCap: hitRecordCap,
        skippedMixedCurrency: skippedMixed + skippedMixedCurrencyTransactions,
        upcomingAfterHorizonMinor: upcomingAfter,
        currencyCode: currencyCode,
      ),
      countedCommitments: counted,
      skippedMixedCurrency: skippedMixed + skippedMixedCurrencyTransactions,
    );
  }

  static List<String> _assumptions({
    required ForecastHorizon horizon,
    required BusinessZone zone,
  }) {
    return [
      'Recorded cash is the starting figure. Unpaid commitments are not subtracted from that recorded total.',
      'This ${horizon.label} outlook uses ${zone.name} calendar days, from today through the last day of the window.',
      'Incoming cash is not forecast. Unpaid recorded sales have no payment due date, so they are not treated as expected receipts.',
      'Known unpaid commitments due in this window, including overdue bills, are the only projected outflows.',
      'Paid and cancelled commitments, paid expenses, and inventory value are not treated as future cash movements here.',
      'This is a projection from saved records, not a guarantee and not professional accounting, tax or investment advice.',
    ];
  }

  static List<ForecastLimitation> _limitations({
    required int unpaidSalesMinor,
    required int unpaidExpensesMinor,
    required int inventoryValueMinor,
    required bool hitRecordCap,
    required int skippedMixedCurrency,
    required int upcomingAfterHorizonMinor,
    required String currencyCode,
  }) {
    final limitations = <ForecastLimitation>[
      const ForecastLimitation(
        code: incomingNotForecast,
        message:
            'Incoming cash is not forecast. Unpaid sales have no due date.',
      ),
    ];
    if (unpaidSalesMinor > 0) {
      limitations.add(
        ForecastLimitation(
          code: incomingNotForecast,
          message:
              'Unpaid sales stay in sales, not cash, and are not projected as receipts.',
        ),
      );
    }
    if (unpaidExpensesMinor > 0) {
      limitations.add(
        const ForecastLimitation(
          code: unpaidExpensesNotDated,
          message: 'Undated unpaid expenses are not treated as bills here.',
        ),
      );
    }
    if (inventoryValueMinor != 0) {
      limitations.add(
        const ForecastLimitation(
          code: inventoryNotCash,
          message: 'Stock value is not cash.',
        ),
      );
    }
    if (hitRecordCap) {
      limitations.add(
        const ForecastLimitation(
          code: incompleteHistory,
          message: 'Uses the latest 5,000 transactions.',
        ),
      );
    }
    if (skippedMixedCurrency > 0) {
      limitations.add(
        ForecastLimitation(
          code: mixedCurrency,
          message:
              skippedMixedCurrency == 1
                  ? '1 row in another currency was left out of these $currencyCode figures.'
                  : '$skippedMixedCurrency rows in another currency were left out of these $currencyCode figures.',
        ),
      );
    }
    if (upcomingAfterHorizonMinor > 0) {
      limitations.add(
        const ForecastLimitation(
          code: commitmentsBeyondHorizon,
          message: 'Some bills fall after this window.',
        ),
      );
    }
    return List<ForecastLimitation>.unmodifiable(limitations);
  }

  static void _validateAmount(int amountMinor) {
    if (amountMinor < MoneyLimits.minPositiveMinorUnits ||
        amountMinor > MoneyLimits.maxMinorUnits) {
      throw const FinanceException(
        'A commitment amount must be a positive amount within the supported range.',
      );
    }
  }

  static int _add(int left, int right) {
    if (right > 0 && left > MoneyLimits.maxSignedTotal - right) {
      throw const FinanceException(
        'A financial total exceeded the supported range.',
      );
    }
    if (right < 0 && left < MoneyLimits.minSignedTotal - right) {
      throw const FinanceException(
        'A financial total exceeded the supported range.',
      );
    }
    return left + right;
  }
}

class _DayBucket {
  int outflowMinor = 0;
  final List<String> ids = [];
}
