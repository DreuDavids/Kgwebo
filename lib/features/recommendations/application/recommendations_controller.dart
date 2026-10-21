import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/finance/business_calendar.dart';
import '../../../core/finance/cash_forecast.dart';
import '../../../core/finance/cash_outlook.dart';
import '../../../core/finance/financial_engine.dart';
import '../../../core/finance/recommendation_lifecycle.dart';
import '../../../core/finance/recommendation_rules.dart';
import '../../../core/inventory/inventory_insights.dart';
import '../../authentication/application/session_controller.dart';
import '../../authentication/domain/app_session.dart';
import '../../authentication/domain/auth_failure.dart';
import '../../obligations/application/obligation_repository.dart';
import '../../obligations/application/obligation_tick.dart';
import '../../obligations/domain/business_obligation.dart';
import '../../products/application/product_repository.dart';
import '../../products/application/product_tick.dart';
import '../../products/domain/catalog_product.dart';
import '../../transactions/application/transaction_repository.dart';
import '../../transactions/application/transaction_tick.dart';
import '../../transactions/domain/business_transaction.dart';
import '../domain/business_recommendation.dart';
import '../domain/visible_recommendation.dart';
import 'recommendation_repository.dart';
import 'recommendation_tick.dart';

class RecommendationsViewState {
  const RecommendationsViewState({
    this.loading = false,
    this.items = const [],
    this.isStale = false,
    this.isPreview = false,
    this.failedRefresh = false,
    this.error,
  });

  final bool loading;
  final List<VisibleRecommendation> items;
  final bool isStale;
  final bool isPreview;
  final bool failedRefresh;
  final String? error;

  List<VisibleRecommendation> get dashboardItems => items.take(3).toList();
}

final recommendationsControllerProvider = StateNotifierProvider.autoDispose<
  RecommendationsController,
  RecommendationsViewState
>((ref) {
  final controller = RecommendationsController(
    session: ref.watch(appSessionProvider),
    recommendations: ref.watch(recommendationRepositoryProvider),
    transactions: ref.watch(transactionRepositoryProvider),
    obligations: ref.watch(obligationRepositoryProvider),
    products: ref.watch(productRepositoryProvider),
  );
  ref.listen<int>(transactionTickProvider, (_, __) {
    controller.refresh();
  });
  ref.listen<int>(obligationTickProvider, (_, __) {
    controller.refresh();
  });
  ref.listen<int>(productTickProvider, (_, __) {
    controller.refresh();
  });
  ref.listen<int>(recommendationTickProvider, (_, __) {
    controller.refresh();
  });
  return controller;
});

class RecommendationsController
    extends StateNotifier<RecommendationsViewState> {
  RecommendationsController({
    required AppSession session,
    required RecommendationRepository recommendations,
    required TransactionRepository transactions,
    required ObligationRepository obligations,
    required ProductRepository products,
  }) : _session = session,
       _recommendations = recommendations,
       _transactions = transactions,
       _obligations = obligations,
       _products = products,
       super(const RecommendationsViewState(loading: true)) {
    _load();
  }

  final AppSession _session;
  final RecommendationRepository _recommendations;
  final TransactionRepository _transactions;
  final ObligationRepository _obligations;
  final ProductRepository _products;

  Future<void> refresh() => _load();

  Future<void> dismiss(VisibleRecommendation item) async {
    final session = _session;
    if (session is! AppSessionReady) {
      return;
    }
    final persisted = item.persisted;
    if (persisted == null) {
      return;
    }
    try {
      await _recommendations.dismiss(
        ownerId: session.user.id,
        businessId: session.business.id,
        recommendationId: persisted.id,
        conditionKey: item.generated.conditionKey,
      );
      if (!mounted) {
        return;
      }
      state = RecommendationsViewState(
        items: [
          for (final current in state.items)
            if (current.ruleKey != item.ruleKey) current,
        ],
        isStale: state.isStale,
        error: state.error,
      );
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }
      state = RecommendationsViewState(
        items: state.items,
        isStale: true,
        failedRefresh: state.failedRefresh,
        error: error.message,
      );
    }
  }

  Future<void> _load() async {
    final session = _session;
    if (session is AppSessionPreview) {
      state = const RecommendationsViewState(isPreview: true);
      return;
    }
    if (session is! AppSessionReady) {
      state = const RecommendationsViewState();
      return;
    }

    state = RecommendationsViewState(
      loading: true,
      items: state.items,
      isStale: state.isStale,
      error: state.error,
    );

    try {
      final snapshot = await _recommendations.listAllConfirmed(
        ownerId: session.user.id,
        businessId: session.business.id,
      );
      final records = await _safeTransactions(session);
      final commitments = await _safeObligations(session);
      final products = await _safeProducts(session);
      if (!mounted) {
        return;
      }
      final generated = _generate(
        session: session,
        records: records,
        commitments: commitments,
        products: products,
      );
      var persisted = snapshot.items;
      if (!snapshot.isStale) {
        persisted = await _sync(
          session: session,
          existing: persisted,
          generated: generated,
        );
      }
      if (!mounted) {
        return;
      }
      state = RecommendationsViewState(
        items: _visible(generated, persisted),
        isStale: snapshot.isStale,
        error: snapshot.refreshError,
        failedRefresh: false,
      );
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }
      if (state.items.isNotEmpty) {
        state = RecommendationsViewState(
          items: state.items,
          isStale: true,
          failedRefresh: true,
          error: error.message,
        );
        return;
      }
      state = RecommendationsViewState(
        isStale: true,
        failedRefresh: true,
        error: error.message,
      );
    }
  }

  List<GeneratedRecommendation> _generate({
    required AppSessionReady session,
    required List<BusinessTransaction> records,
    required List<BusinessObligation>? commitments,
    required List<CatalogProduct> products,
  }) {
    final now = DateTime.now().toUtc();
    final zone = BusinessZone.forCountry(session.business.countryCode);
    final completed = FinancialEngine.summarize(
      entries: [for (final item in records) item.toLedgerEntry()],
      openingCashMinor: session.business.openingBalanceMinor,
      currencyCode: session.business.currencyCode,
      period: BusinessCalendar.previousMonth(now, zone: zone),
      asOf: now,
    );
    final outlook =
        commitments == null
            ? null
            : CashOutlookEngine.summarize(
              currentCashMinor: completed.currentCashMinor,
              currencyCode: session.business.currencyCode,
              asOf: now,
              zone: zone,
              commitments: commitments.map(
                (item) => item.toScheduledCommitment(),
              ),
            );
    final cash = completed.currentCashMinor;
    final forecast =
        commitments == null
            ? null
            : CashForecastEngine.project(
              currentCashMinor: cash,
              currencyCode: session.business.currencyCode,
              asOf: now,
              zone: zone,
              horizon: ForecastHorizon.days14,
              commitments: commitments.map(
                (item) => item.toScheduledCommitment(),
              ),
            );
    final overdueIds = [
      if (commitments != null)
        for (final item in commitments)
          if (item.displayStatus(asOf: now, zone: zone) ==
              ObligationDisplayStatus.overdue)
            item.id,
    ];
    return RecommendationRules.evaluate(
      completedPeriodSummary: completed,
      outlook: outlook,
      forecast14: forecast,
      inventory: InventoryInsights.fromProducts(products),
      overdueCommitmentIds: overdueIds,
    );
  }

  Future<List<BusinessRecommendation>> _sync({
    required AppSessionReady session,
    required List<BusinessRecommendation> existing,
    required List<GeneratedRecommendation> generated,
  }) async {
    final mutations = RecommendationLifecycle.reconcile(
      existing: [for (final row in existing) row.toPersistedState()],
      generated: generated,
    );
    var next = [...existing];
    for (final mutation in mutations) {
      try {
        final saved = await _recommendations.upsert(
          ownerId: session.user.id,
          businessId: session.business.id,
          mutation: mutation,
        );
        final index = next.indexWhere((row) => row.ruleKey == saved.ruleKey);
        if (index >= 0) {
          next[index] = saved;
        } else {
          next.add(saved);
        }
      } on AuthFailure {
        // Keep last confirmed state. Visibility still uses generated + existing.
      }
    }
    return next;
  }

  List<VisibleRecommendation> _visible(
    List<GeneratedRecommendation> generated,
    List<BusinessRecommendation> persisted,
  ) {
    final byRule = <RecommendationRuleKey, BusinessRecommendation>{
      for (final row in persisted) row.ruleKey: row,
    };
    final visible = <VisibleRecommendation>[];
    for (final item in generated) {
      final stored = byRule[item.ruleKey];
      if (!RecommendationLifecycle.isVisibleActive(
        generated: item,
        persisted: stored?.toPersistedState(),
      )) {
        continue;
      }
      visible.add(VisibleRecommendation(generated: item, persisted: stored));
    }
    visible.sort((a, b) {
      final bySeverity = a.severity.index.compareTo(b.severity.index);
      if (bySeverity != 0) {
        return bySeverity;
      }
      return a.ruleKey.storage.compareTo(b.ruleKey.storage);
    });
    return visible;
  }

  Future<List<BusinessTransaction>> _safeTransactions(
    AppSessionReady session,
  ) async {
    try {
      final snapshot = await _transactions.listAllConfirmed(
        ownerId: session.user.id,
        businessId: session.business.id,
      );
      return snapshot.items;
    } on AuthFailure {
      return const [];
    }
  }

  Future<List<BusinessObligation>?> _safeObligations(
    AppSessionReady session,
  ) async {
    try {
      final snapshot = await _obligations.listAllConfirmed(
        ownerId: session.user.id,
        businessId: session.business.id,
      );
      return snapshot.items;
    } on AuthFailure {
      return null;
    }
  }

  Future<List<CatalogProduct>> _safeProducts(AppSessionReady session) async {
    try {
      final snapshot = await _products.listAllConfirmed(
        ownerId: session.user.id,
        businessId: session.business.id,
      );
      return snapshot.items;
    } on AuthFailure {
      return const [];
    }
  }
}
