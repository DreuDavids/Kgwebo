import '../money/money_limits.dart';
import 'business_calendar.dart';
import 'finance_exception.dart';

enum CommitmentStatus { unpaid, paid, cancelled }

/// A scheduled business payment that is not itself a recorded expense.
class ScheduledCommitment {
  const ScheduledCommitment({
    required this.id,
    required this.amountMinor,
    required this.currencyCode,
    required this.dueOn,
    required this.status,
  });

  final String id;
  final int amountMinor;
  final String currencyCode;
  final DateTime dueOn;
  final CommitmentStatus status;
}

/// Recorded cash plus unpaid commitments. The estimate is never guaranteed cash.
class CashOutlook {
  const CashOutlook({
    required this.currencyCode,
    required this.currentCashMinor,
    required this.unpaidUpcomingMinor,
    required this.overdueMinor,
    required this.unpaidCommitmentsMinor,
    required this.estimatedCashAfterCommitmentsMinor,
    required this.countedCommitments,
    required this.skippedMixedCurrency,
  });

  final String currencyCode;
  final int currentCashMinor;
  final int unpaidUpcomingMinor;
  final int overdueMinor;
  final int unpaidCommitmentsMinor;
  final int estimatedCashAfterCommitmentsMinor;
  final int countedCommitments;
  final int skippedMixedCurrency;
}

abstract final class CashOutlookEngine {
  static CashOutlook summarize({
    required int currentCashMinor,
    required String currencyCode,
    required Iterable<ScheduledCommitment> commitments,
    required DateTime asOf,
    BusinessZone zone = BusinessZone.africaGaborone,
  }) {
    if (currencyCode.trim().length != 3) {
      throw const FinanceException('A three-letter currency code is required.');
    }

    final asOfWall = BusinessCalendar.wallTime(asOf, zone);
    final asOfDate = DateTime(asOfWall.year, asOfWall.month, asOfWall.day);
    final seenIds = <String>{};
    var upcoming = 0;
    var overdue = 0;
    var counted = 0;
    var skippedMixed = 0;

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
      } else {
        upcoming = _add(upcoming, commitment.amountMinor);
      }
    }

    final unpaid = _add(upcoming, overdue);
    return CashOutlook(
      currencyCode: currencyCode,
      currentCashMinor: currentCashMinor,
      unpaidUpcomingMinor: upcoming,
      overdueMinor: overdue,
      unpaidCommitmentsMinor: unpaid,
      estimatedCashAfterCommitmentsMinor: _add(currentCashMinor, -unpaid),
      countedCommitments: counted,
      skippedMixedCurrency: skippedMixed,
    );
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
