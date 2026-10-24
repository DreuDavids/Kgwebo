import 'cash_forecast.dart';

/// A named unpaid commitment used to label drops on a cash path.
class CashPathBill {
  const CashPathBill({
    required this.id,
    required this.title,
    required this.amountMinor,
    required this.dueOn,
  });

  final String id;
  final String title;
  final int amountMinor;
  final DateTime dueOn;
}

class CashPathDrop {
  const CashPathDrop({
    required this.commitmentId,
    required this.title,
    required this.dueOn,
    required this.amountMinor,
    required this.cashAfterMinor,
    required this.isOverdue,
  });

  final String commitmentId;
  final String title;
  final DateTime dueOn;
  final int amountMinor;
  final int cashAfterMinor;
  final bool isOverdue;
}

/// Labelled cash path for a forecast window. Plotting uses integer minor units;
/// [double] is never the source of totals.
class CashPath {
  const CashPath({
    required this.startCashMinor,
    required this.endCashMinor,
    required this.seriesMinor,
    required this.drops,
    required this.startDate,
    required this.endDate,
    required this.currencyCode,
    required this.horizon,
  });

  final int startCashMinor;
  final int endCashMinor;
  final List<int> seriesMinor;
  final List<CashPathDrop> drops;
  final DateTime startDate;
  final DateTime endDate;
  final String currencyCode;
  final ForecastHorizon horizon;

  bool get hasChart => seriesMinor.length >= 2 && drops.isNotEmpty;

  int get minCashMinor {
    if (seriesMinor.isEmpty) {
      return 0;
    }
    var min = seriesMinor.first;
    for (final value in seriesMinor) {
      if (value < min) {
        min = value;
      }
    }
    return min;
  }

  int get maxCashMinor {
    if (seriesMinor.isEmpty) {
      return 0;
    }
    var max = seriesMinor.first;
    for (final value in seriesMinor) {
      if (value > max) {
        max = value;
      }
    }
    return max;
  }

  static CashPath fromForecast({
    required CashForecast forecast,
    required Iterable<CashPathBill> bills,
  }) {
    final byId = <String, CashPathBill>{
      for (final bill in bills) bill.id: bill,
    };
    if (!forecast.hasProjectedPath) {
      return CashPath(
        startCashMinor: forecast.currentCashMinor,
        endCashMinor: forecast.estimatedCashAfterKnownCommitmentsMinor,
        seriesMinor: const [],
        drops: const [],
        startDate: forecast.asOfDate,
        endDate: forecast.horizonEndDate,
        currencyCode: forecast.currencyCode,
        horizon: forecast.horizon,
      );
    }

    final series = <int>[forecast.currentCashMinor];
    final drops = <CashPathDrop>[];
    var running = forecast.currentCashMinor;

    for (final day in forecast.daily) {
      series.add(day.projectedCashMinor);
      for (final id in day.commitmentIds) {
        final bill = byId[id];
        final amount = bill?.amountMinor ?? 0;
        running -= amount;
        drops.add(
          CashPathDrop(
            commitmentId: id,
            title: _titleFor(bill),
            dueOn: bill?.dueOn ?? day.wallDate,
            amountMinor: amount,
            cashAfterMinor: running,
            isOverdue:
                bill != null && _isOverdue(bill.dueOn, forecast.asOfDate),
          ),
        );
      }
      running = day.projectedCashMinor;
    }

    return CashPath(
      startCashMinor: forecast.currentCashMinor,
      endCashMinor: forecast.estimatedCashAfterKnownCommitmentsMinor,
      seriesMinor: List<int>.unmodifiable(series),
      drops: List<CashPathDrop>.unmodifiable(drops),
      startDate: forecast.asOfDate,
      endDate: forecast.horizonEndDate,
      currencyCode: forecast.currencyCode,
      horizon: forecast.horizon,
    );
  }

  static String _titleFor(CashPathBill? bill) {
    final title = bill?.title.trim() ?? '';
    if (title.isEmpty) {
      return 'Unnamed commitment';
    }
    return title;
  }

  static bool _isOverdue(DateTime dueOn, DateTime asOfDate) {
    final due = DateTime(dueOn.year, dueOn.month, dueOn.day);
    return due.isBefore(asOfDate);
  }
}
