import '../inventory/inventory_insights.dart';
import '../money/money_formatter.dart';
import 'cash_forecast.dart';
import 'cash_outlook.dart';
import 'financial_summary.dart';

enum RecommendationRuleKey {
  overdueCommitments('overdue_commitments'),
  cashShortfall('cash_shortfall'),
  tightCashAfterCommitments('tight_cash_after_commitments'),
  expensesExceedSales('expenses_exceed_sales'),
  lowStock('low_stock'),
  incompleteProductCost('incomplete_product_cost');

  const RecommendationRuleKey(this.storage);

  final String storage;

  static RecommendationRuleKey parse(String raw) {
    for (final value in RecommendationRuleKey.values) {
      if (value.storage == raw) {
        return value;
      }
    }
    throw FormatException('Unknown recommendation rule', raw);
  }
}

enum RecommendationCategory { cash, commitments, operations, inventory }

enum RecommendationSeverity { high, medium, low }

enum RecommendationDestination {
  cashFlow,
  overdueCommitments,
  transactions,
  products,
}

class GeneratedRecommendation {
  const GeneratedRecommendation({
    required this.ruleKey,
    required this.conditionKey,
    required this.category,
    required this.severity,
    required this.title,
    required this.explanation,
    required this.evidence,
    required this.suggestedAction,
    required this.destination,
  });

  final RecommendationRuleKey ruleKey;
  final String conditionKey;
  final RecommendationCategory category;
  final RecommendationSeverity severity;
  final String title;
  final String explanation;
  final String evidence;
  final String suggestedAction;
  final RecommendationDestination destination;
}

/// Deterministic recommendation rules. Empty businesses do not get scare copy.
abstract final class RecommendationRules {
  static const severalLowStock = 2;
  static const tightCashRemainderNumerator = 1;
  static const tightCashRemainderDenominator = 5;

  static List<GeneratedRecommendation> evaluate({
    required FinancialSummary completedPeriodSummary,
    required CashOutlook? outlook,
    required CashForecast? forecast14,
    required InventoryInsights inventory,
    List<String> overdueCommitmentIds = const [],
  }) {
    final generated = <GeneratedRecommendation>[];
    if (outlook != null && outlook.overdueMinor > 0) {
      generated.add(_overdue(outlook, overdueCommitmentIds));
    }
    if (forecast14 != null) {
      final shortfall = _shortfall(forecast14);
      if (shortfall != null) {
        generated.add(shortfall);
      } else {
        final tight = _tightCash(forecast14);
        if (tight != null) {
          generated.add(tight);
        }
      }
    }
    final expenses = _expensesExceedSales(completedPeriodSummary);
    if (expenses != null) {
      generated.add(expenses);
    }
    final stock = _lowStock(inventory);
    if (stock != null) {
      generated.add(stock);
    }
    final cost = _incompleteCost(inventory);
    if (cost != null) {
      generated.add(cost);
    }
    return List<GeneratedRecommendation>.unmodifiable(generated);
  }

  static GeneratedRecommendation _overdue(
    CashOutlook outlook,
    List<String> overdueCommitmentIds,
  ) {
    final amount = MoneyFormatter.formatMinor(
      outlook.overdueMinor,
      currencyCode: outlook.currencyCode,
    );
    final ids = [...overdueCommitmentIds]..sort();
    return GeneratedRecommendation(
      ruleKey: RecommendationRuleKey.overdueCommitments,
      conditionKey: 'overdue:${ids.join(',')}',
      category: RecommendationCategory.commitments,
      severity: RecommendationSeverity.high,
      title: 'An unpaid commitment is overdue',
      explanation:
          'Saved commitments past their due date still need a decision. They have not reduced recorded cash and are not recorded operating expenses until you record a paid expense.',
      evidence: '$amount in unpaid commitments is past due.',
      suggestedAction: 'Review overdue commitments',
      destination: RecommendationDestination.overdueCommitments,
    );
  }

  static GeneratedRecommendation? _shortfall(CashForecast forecast) {
    if (!forecast.hasKnownOutflows) {
      return null;
    }
    if (forecast.estimatedCashAfterKnownCommitmentsMinor > 0) {
      return null;
    }
    final estimated = MoneyFormatter.formatMinor(
      forecast.estimatedCashAfterKnownCommitmentsMinor,
      currencyCode: forecast.currencyCode,
    );
    final cash = MoneyFormatter.formatMinor(
      forecast.currentCashMinor,
      currencyCode: forecast.currencyCode,
    );
    final due = MoneyFormatter.formatMinor(
      forecast.overdueMinor + forecast.upcomingWithinHorizonMinor,
      currencyCode: forecast.currencyCode,
    );
    return GeneratedRecommendation(
      ruleKey: RecommendationRuleKey.cashShortfall,
      conditionKey: _forecastCondition(forecast),
      category: RecommendationCategory.cash,
      severity: RecommendationSeverity.high,
      title: 'Known commitments may use all recorded cash',
      explanation:
          'This is an estimate from recorded cash and unpaid commitments in the next 14 days. It is not a guarantee that cash will run out, and it does not invent future sales.',
      evidence:
          'Recorded cash $cash minus known unpaid commitments $due leaves an estimated $estimated after those bills.',
      suggestedAction: 'Open Cash Flow',
      destination: RecommendationDestination.cashFlow,
    );
  }

  static GeneratedRecommendation? _tightCash(CashForecast forecast) {
    if (!forecast.hasKnownOutflows) {
      return null;
    }
    final remaining = forecast.estimatedCashAfterKnownCommitmentsMinor;
    final cash = forecast.currentCashMinor;
    if (remaining <= 0 || cash <= 0) {
      return null;
    }
    if (remaining * tightCashRemainderDenominator >=
        cash * tightCashRemainderNumerator) {
      return null;
    }
    final remainingLabel = MoneyFormatter.formatMinor(
      remaining,
      currencyCode: forecast.currencyCode,
    );
    final cashLabel = MoneyFormatter.formatMinor(
      cash,
      currencyCode: forecast.currencyCode,
    );
    final due = MoneyFormatter.formatMinor(
      forecast.overdueMinor + forecast.upcomingWithinHorizonMinor,
      currencyCode: forecast.currencyCode,
    );
    return GeneratedRecommendation(
      ruleKey: RecommendationRuleKey.tightCashAfterCommitments,
      conditionKey: _forecastCondition(forecast),
      category: RecommendationCategory.cash,
      severity: RecommendationSeverity.medium,
      title: 'An upcoming commitment may leave little recorded cash',
      explanation:
          'After unpaid commitments due in the next 14 days, estimated remaining cash would be small compared with recorded cash. This is an estimate, not a shortage warning.',
      evidence:
          'Recorded cash $cashLabel minus known unpaid commitments $due leaves an estimated $remainingLabel.',
      suggestedAction: 'Open Cash Flow',
      destination: RecommendationDestination.cashFlow,
    );
  }

  static GeneratedRecommendation? _expensesExceedSales(
    FinancialSummary summary,
  ) {
    final hasActivity =
        summary.recordedSalesMinor != 0 ||
        summary.recordedOperatingExpensesMinor != 0 ||
        summary.recordedRefundsMinor != 0;
    if (!hasActivity || summary.netRecordedOperatingResultMinor >= 0) {
      return null;
    }
    final currency = summary.currencyCode;
    return GeneratedRecommendation(
      ruleKey: RecommendationRuleKey.expensesExceedSales,
      conditionKey:
          'period:${summary.period.startInclusive.toUtc().toIso8601String()}',
      category: RecommendationCategory.operations,
      severity: RecommendationSeverity.medium,
      title: 'Operating expenses exceeded recorded sales last month',
      explanation:
          'This compares recorded sales, refunds and operating expenses for the completed calendar month. It is not cash on hand, taxable income or audited profit.',
      evidence:
          'Recorded sales ${MoneyFormatter.formatMinor(summary.recordedSalesMinor, currencyCode: currency)} minus refunds ${MoneyFormatter.formatMinor(summary.recordedRefundsMinor, currencyCode: currency)} and operating expenses ${MoneyFormatter.formatMinor(summary.recordedOperatingExpensesMinor, currencyCode: currency)} left ${MoneyFormatter.formatMinor(summary.netRecordedOperatingResultMinor, currencyCode: currency)}.',
      suggestedAction: 'Review transactions',
      destination: RecommendationDestination.transactions,
    );
  }

  static GeneratedRecommendation? _lowStock(InventoryInsights inventory) {
    final count = inventory.restockProductIds.length;
    if (count < severalLowStock) {
      return null;
    }
    final ids = [...inventory.restockProductIds]..sort();
    return GeneratedRecommendation(
      ruleKey: RecommendationRuleKey.lowStock,
      conditionKey: 'products:${ids.join(',')}',
      category: RecommendationCategory.inventory,
      severity: RecommendationSeverity.medium,
      title: 'Several products are low on stock',
      explanation:
          'Low-stock and out-of-stock counts use saved catalogue quantities. Inventory value is not cash.',
      evidence:
          '$count active products are at or below their restock threshold.',
      suggestedAction: 'View low-stock products',
      destination: RecommendationDestination.products,
    );
  }

  static GeneratedRecommendation? _incompleteCost(InventoryInsights inventory) {
    if (inventory.missingCostCount <= 0 || inventory.activeCount <= 0) {
      return null;
    }
    final ids = [...inventory.missingCostProductIds]..sort();
    return GeneratedRecommendation(
      ruleKey: RecommendationRuleKey.incompleteProductCost,
      conditionKey: 'missing-cost:${ids.join(',')}',
      category: RecommendationCategory.inventory,
      severity: RecommendationSeverity.low,
      title: 'Product cost information is incomplete',
      explanation:
          'Estimated inventory value only includes products with a recorded cost. Missing costs are excluded, not invented.',
      evidence:
          '${inventory.missingCostCount} of ${inventory.activeCount} active products have no recorded cost, so inventory valuation is incomplete.',
      suggestedAction: 'Review product costs',
      destination: RecommendationDestination.products,
    );
  }

  static String _forecastCondition(CashForecast forecast) {
    final ids = [for (final day in forecast.daily) ...day.commitmentIds]
      ..sort();
    return 'commitments:${ids.join(',')}';
  }
}
