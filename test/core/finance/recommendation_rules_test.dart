import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/business_calendar.dart';
import 'package:kgwebo/core/finance/cash_forecast.dart';
import 'package:kgwebo/core/finance/cash_outlook.dart';
import 'package:kgwebo/core/finance/financial_engine.dart';
import 'package:kgwebo/core/finance/financial_summary.dart';
import 'package:kgwebo/core/finance/ledger_entry.dart';
import 'package:kgwebo/core/finance/recommendation_rules.dart';
import 'package:kgwebo/core/inventory/inventory_insights.dart';
import 'package:kgwebo/core/inventory/unit_of_measure.dart';
import 'package:kgwebo/features/products/domain/catalog_product.dart';

void main() {
  const zone = BusinessZone.africaGaborone;
  final asOf = DateTime.utc(2026, 10, 21, 12);
  final lastMonth = BusinessCalendar.previousMonth(asOf, zone: zone);
  final emptyInventory = InventoryInsights.fromProducts(const []);

  FinancialSummary lastMonthSummary({
    int sales = 0,
    int expenses = 0,
    int opening = 200000,
  }) {
    return FinancialEngine.summarize(
      entries: [
        if (sales > 0)
          LedgerEntry(
            id: 'sale',
            type: MoneyMovementType.sale,
            amountMinor: sales,
            currencyCode: 'BWP',
            occurredAt: DateTime.utc(2026, 9, 10),
            paymentStatus: PaymentStatus.paid,
          ),
        if (expenses > 0)
          LedgerEntry(
            id: 'exp',
            type: MoneyMovementType.expense,
            amountMinor: expenses,
            currencyCode: 'BWP',
            occurredAt: DateTime.utc(2026, 9, 12),
            paymentStatus: PaymentStatus.paid,
          ),
      ],
      openingCashMinor: opening,
      currencyCode: 'BWP',
      period: lastMonth,
      asOf: asOf,
    );
  }

  CashForecast forecast14({
    int cash = 200000,
    Iterable<ScheduledCommitment> commitments = const [],
  }) {
    return CashForecastEngine.project(
      currentCashMinor: cash,
      currencyCode: 'BWP',
      asOf: asOf,
      zone: zone,
      horizon: ForecastHorizon.days14,
      commitments: commitments,
    );
  }

  List<GeneratedRecommendation> evaluate({
    FinancialSummary? completed,
    CashOutlook? outlook,
    CashForecast? forecast,
    InventoryInsights? inventory,
    List<String> overdueIds = const [],
  }) {
    return RecommendationRules.evaluate(
      completedPeriodSummary: completed ?? lastMonthSummary(),
      outlook: outlook,
      forecast14: forecast,
      inventory: inventory ?? emptyInventory,
      overdueCommitmentIds: overdueIds,
    );
  }

  test('empty businesses do not receive scare recommendations', () {
    final outlook = CashOutlookEngine.summarize(
      currentCashMinor: 200000,
      currencyCode: 'BWP',
      asOf: asOf,
      commitments: const [],
    );
    final recs = evaluate(outlook: outlook, forecast: forecast14());
    expect(recs, isEmpty);
  });

  test('overdue commitments generate an evidence-backed recommendation', () {
    final outlook = CashOutlookEngine.summarize(
      currentCashMinor: 200000,
      currencyCode: 'BWP',
      asOf: asOf,
      commitments: [
        ScheduledCommitment(
          id: 'rent',
          amountMinor: 80000,
          currencyCode: 'BWP',
          dueOn: DateTime(2026, 10, 1),
          status: CommitmentStatus.unpaid,
        ),
      ],
    );
    final recs = evaluate(
      outlook: outlook,
      forecast: forecast14(
        commitments: [
          ScheduledCommitment(
            id: 'rent',
            amountMinor: 80000,
            currencyCode: 'BWP',
            dueOn: DateTime(2026, 10, 1),
            status: CommitmentStatus.unpaid,
          ),
        ],
      ),
      overdueIds: const ['rent'],
    );

    expect(
      recs.map((item) => item.ruleKey),
      contains(RecommendationRuleKey.overdueCommitments),
    );
    final overdue = recs.singleWhere(
      (item) => item.ruleKey == RecommendationRuleKey.overdueCommitments,
    );
    expect(overdue.evidence, contains('P 800.00'));
    expect(overdue.explanation.toLowerCase(), isNot(contains('guarantee')));
    expect(overdue.conditionKey, 'overdue:rent');
  });

  test(
    'known commitments that consume recorded cash create a shortfall rec',
    () {
      final recs = evaluate(
        forecast: forecast14(
          cash: 50000,
          commitments: [
            ScheduledCommitment(
              id: 'rent',
              amountMinor: 80000,
              currencyCode: 'BWP',
              dueOn: DateTime(2026, 10, 24),
              status: CommitmentStatus.unpaid,
            ),
          ],
        ),
      );
      final shortfall = recs.singleWhere(
        (item) => item.ruleKey == RecommendationRuleKey.cashShortfall,
      );
      expect(shortfall.evidence, contains('P 500.00'));
      expect(shortfall.explanation.toLowerCase(), contains('estimate'));
      expect(
        recs.map((item) => item.ruleKey),
        isNot(contains(RecommendationRuleKey.tightCashAfterCommitments)),
      );
    },
  );

  test(
    'upcoming commitments that leave little cash are labelled an estimate',
    () {
      final recs = evaluate(
        forecast: forecast14(
          cash: 100000,
          commitments: [
            ScheduledCommitment(
              id: 'rent',
              amountMinor: 90000,
              currencyCode: 'BWP',
              dueOn: DateTime(2026, 10, 24),
              status: CommitmentStatus.unpaid,
            ),
          ],
        ),
      );
      expect(
        recs.map((item) => item.ruleKey),
        contains(RecommendationRuleKey.tightCashAfterCommitments),
      );
      expect(recs.single.explanation.toLowerCase(), contains('estimate'));
    },
  );

  test('expenses exceeding sales fire only for a completed period', () {
    final recs = evaluate(
      completed: lastMonthSummary(sales: 10000, expenses: 40000),
    );
    expect(
      recs.map((item) => item.ruleKey),
      contains(RecommendationRuleKey.expensesExceedSales),
    );
    expect(recs.single.evidence, contains('P 100.00'));
    expect(recs.single.title.toLowerCase(), contains('last month'));
  });

  test('several low-stock products generate a restock recommendation', () {
    final recs = evaluate(
      inventory: InventoryInsights.fromProducts([
        _product(id: 'a', quantityMilli: 0),
        _product(id: 'b', quantityMilli: 500, threshold: 2000),
        _product(id: 'c', quantityMilli: 8000, threshold: 2000),
      ]),
    );
    expect(
      recs.map((item) => item.ruleKey),
      contains(RecommendationRuleKey.lowStock),
    );
    expect(recs.single.conditionKey, 'products:a,b');
  });

  test('a single low-stock product is not several products', () {
    final recs = evaluate(
      inventory: InventoryInsights.fromProducts([
        _product(id: 'a', quantityMilli: 0),
      ]),
    );
    expect(
      recs.map((item) => item.ruleKey),
      isNot(contains(RecommendationRuleKey.lowStock)),
    );
  });

  test('missing product costs limit inventory valuation', () {
    final recs = evaluate(
      inventory: InventoryInsights.fromProducts([
        _product(id: 'a', quantityMilli: 5000, cost: null),
        _product(id: 'b', quantityMilli: 5000, cost: 800),
      ]),
    );
    final missing = recs.singleWhere(
      (item) => item.ruleKey == RecommendationRuleKey.incompleteProductCost,
    );
    expect(missing.conditionKey, 'missing-cost:a');
    expect(missing.explanation.toLowerCase(), contains('not invented'));
  });
}

CatalogProduct _product({
  required String id,
  required int quantityMilli,
  int? cost = 800,
  int? threshold = 2000,
}) {
  return CatalogProduct(
    id: id,
    businessId: 'biz-1',
    ownerId: 'user-1',
    createdBy: 'user-1',
    name: id,
    sellingPriceMinor: 1250,
    unitCostMinor: cost,
    stockQuantityMilli: quantityMilli,
    lowStockThresholdMilli: threshold,
    unitOfMeasure: UnitOfMeasure.each,
    isActive: true,
    createdAt: DateTime.utc(2026, 10, 21),
    updatedAt: DateTime.utc(2026, 10, 21),
  );
}
