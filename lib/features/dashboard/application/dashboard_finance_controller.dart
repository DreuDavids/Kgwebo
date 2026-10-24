import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/finance/business_calendar.dart';
import '../../../core/finance/cash_forecast.dart';
import '../../../core/finance/cash_outlook.dart';
import '../../../core/finance/dashboard_insights.dart';
import '../../../core/finance/dashboard_period.dart';
import '../../../core/finance/finance_exception.dart';
import '../../../core/finance/financial_engine.dart';
import '../../../core/finance/financial_summary.dart';
import '../../../core/finance/ledger_entry.dart';
import '../../../core/sync/pending_presentation.dart';
import '../../../core/finance/sparkline_series.dart';
import '../../../core/inventory/inventory_insights.dart';
import '../../authentication/application/session_controller.dart';
import '../../authentication/domain/app_session.dart';
import '../../authentication/domain/auth_failure.dart';
import '../../obligations/application/obligation_repository.dart';
import '../../obligations/application/obligation_tick.dart';
import '../../obligations/domain/business_obligation.dart';
import '../../obligations/domain/obligation_snapshot.dart';
import '../../products/application/product_repository.dart';
import '../../products/application/product_tick.dart';
import '../../products/domain/catalog_product.dart';
import '../../transactions/application/transaction_repository.dart';
import '../../transactions/application/transaction_tick.dart';
import '../../transactions/domain/business_transaction.dart';

class DashboardFinanceState {
  const DashboardFinanceState({
    this.loading = false,
    this.summary,
    this.outlook,
    this.insights = const [],
    this.recent = const [],
    this.upcoming = const [],
    this.overdue = const [],
    this.salesSparkline = const [],
    this.isStale = false,
    this.isPreview = false,
    this.periodKind = DashboardPeriodKind.thisMonth,
    this.periodLabel = '',
    this.forecastHorizon = ForecastHorizon.days14,
    this.forecast,
    this.error,
    this.hitRecordCap = false,
  });

  final bool loading;
  final FinancialSummary? summary;
  final CashOutlook? outlook;
  final List<DashboardInsight> insights;
  final List<BusinessTransaction> recent;
  final List<BusinessObligation> upcoming;
  final List<BusinessObligation> overdue;
  final List<double> salesSparkline;
  final bool isStale;
  final bool isPreview;
  final DashboardPeriodKind periodKind;
  final String periodLabel;
  final ForecastHorizon forecastHorizon;
  final CashForecast? forecast;
  final String? error;
  final bool hitRecordCap;

  DashboardFinanceState copyWith({
    bool? loading,
    FinancialSummary? summary,
    CashOutlook? outlook,
    List<DashboardInsight>? insights,
    List<BusinessTransaction>? recent,
    List<BusinessObligation>? upcoming,
    List<BusinessObligation>? overdue,
    List<double>? salesSparkline,
    bool? isStale,
    bool? isPreview,
    DashboardPeriodKind? periodKind,
    String? periodLabel,
    ForecastHorizon? forecastHorizon,
    CashForecast? forecast,
    String? error,
    bool? hitRecordCap,
    bool clearError = false,
    bool clearSummary = false,
  }) {
    return DashboardFinanceState(
      loading: loading ?? this.loading,
      summary: clearSummary ? null : (summary ?? this.summary),
      outlook: clearSummary ? null : (outlook ?? this.outlook),
      insights: insights ?? this.insights,
      recent: recent ?? this.recent,
      upcoming: upcoming ?? this.upcoming,
      overdue: overdue ?? this.overdue,
      salesSparkline: salesSparkline ?? this.salesSparkline,
      isStale: isStale ?? this.isStale,
      isPreview: isPreview ?? this.isPreview,
      periodKind: periodKind ?? this.periodKind,
      periodLabel: periodLabel ?? this.periodLabel,
      forecastHorizon: forecastHorizon ?? this.forecastHorizon,
      forecast: clearSummary ? null : (forecast ?? this.forecast),
      error: clearError ? null : (error ?? this.error),
      hitRecordCap: hitRecordCap ?? this.hitRecordCap,
    );
  }
}

final dashboardFinanceControllerProvider = StateNotifierProvider.autoDispose<
  DashboardFinanceController,
  DashboardFinanceState
>((ref) {
  final controller = DashboardFinanceController(
    session: ref.watch(appSessionProvider),
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
  ref.listen<int>(syncTickProvider, (_, __) {
    controller.refresh();
  });
  return controller;
});

class DashboardFinanceController extends StateNotifier<DashboardFinanceState> {
  DashboardFinanceController({
    required AppSession session,
    required TransactionRepository transactions,
    required ObligationRepository obligations,
    required ProductRepository products,
  }) : _session = session,
       _transactions = transactions,
       _obligations = obligations,
       _products = products,
       super(const DashboardFinanceState(loading: true)) {
    _load();
  }

  final AppSession _session;
  final TransactionRepository _transactions;
  final ObligationRepository _obligations;
  final ProductRepository _products;

  DashboardPeriodKind _kind = DashboardPeriodKind.thisMonth;
  ForecastHorizon _horizon = ForecastHorizon.days14;
  DateTime? _customStart;
  DateTime? _customEnd;
  List<BusinessTransaction>? _records;
  List<BusinessObligation>? _commitments;
  List<CatalogProduct> _productsCached = const [];

  Future<void> refresh() => _load();

  void selectHorizon(ForecastHorizon horizon) {
    _horizon = horizon;
    final records = _records;
    final session = _session;
    if (records != null && session is AppSessionReady) {
      _publish(
        session: session,
        records: records,
        commitments: _commitments,
        isStale: state.isStale,
        error: state.error,
        hitRecordCap: state.hitRecordCap,
      );
    }
  }

  void selectPeriod(
    DashboardPeriodKind kind, {
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    _kind = kind;
    _customStart = customStart;
    _customEnd = customEnd;
    final records = _records;
    final commitments = _commitments;
    final session = _session;
    if (records != null && session is AppSessionReady) {
      _publish(
        session: session,
        records: records,
        commitments: commitments,
        isStale: state.isStale,
        error: state.error,
        hitRecordCap: state.hitRecordCap,
      );
      return;
    }
    _load();
  }

  Future<void> _load() async {
    final session = _session;
    if (session is AppSessionPreview) {
      state = const DashboardFinanceState(isPreview: true);
      return;
    }
    if (session is! AppSessionReady) {
      state = const DashboardFinanceState();
      return;
    }

    final selection = _selection(session);
    state = state.copyWith(
      loading: true,
      periodKind: selection.kind,
      periodLabel: selection.label,
      clearError: true,
    );

    String? txError;
    final txFuture = () async {
      try {
        return await _transactions.listAllConfirmed(
          ownerId: session.user.id,
          businessId: session.business.id,
          onLocalCache: (cached) {
            if (!mounted || cached.items.isEmpty) {
              return;
            }
            _records = cached.items;
            _publish(
              session: session,
              records: cached.items,
              commitments: _commitments,
              isStale: true,
              error: null,
              hitRecordCap: cached.hasMore || cached.items.length >= 5000,
            );
          },
        );
      } on AuthFailure catch (error) {
        txError = error.message;
        return null;
      }
    }();
    final obligationFuture = () async {
      try {
        return await _obligations.listAllConfirmed(
          ownerId: session.user.id,
          businessId: session.business.id,
          onLocalCache: (cached) {
            if (!mounted || cached.items.isEmpty) {
              return;
            }
            _commitments = cached.items;
            final records = _records;
            if (records == null) {
              return;
            }
            _publish(
              session: session,
              records: records,
              commitments: cached.items,
              isStale: true,
              error: null,
              hitRecordCap: state.hitRecordCap,
            );
          },
        );
      } on AuthFailure catch (error) {
        return error;
      }
    }();
    final productFuture = () async {
      try {
        return await _products.listAllConfirmed(
          ownerId: session.user.id,
          businessId: session.business.id,
          onLocalCache: (cached) {
            if (!mounted || cached.items.isEmpty) {
              return;
            }
            _productsCached = cached.items;
            final records = _records;
            if (records == null) {
              return;
            }
            _publish(
              session: session,
              records: records,
              commitments: _commitments,
              isStale: true,
              error: null,
              hitRecordCap: state.hitRecordCap,
            );
          },
        );
      } on AuthFailure {
        return null;
      }
    }();

    final snapshot = await txFuture;
    if (!mounted) {
      return;
    }
    if (snapshot != null) {
      _records = snapshot.items;
      _publish(
        session: session,
        records: snapshot.items,
        commitments: _commitments,
        isStale: session.isStale || snapshot.isStale,
        error: snapshot.refreshError,
        hitRecordCap: snapshot.hasMore || snapshot.items.length >= 5000,
      );
    }

    var commitments = _commitments;
    var outlookKnown = commitments != null;
    var obligationStale = snapshot?.isStale ?? false;
    var obligationError = snapshot?.refreshError ?? txError;
    final obligationResult = await obligationFuture;
    if (!mounted) {
      return;
    }
    if (obligationResult is ObligationListSnapshot) {
      commitments = obligationResult.items;
      outlookKnown = true;
      obligationStale = obligationResult.isStale;
      obligationError =
          snapshot?.refreshError ?? obligationResult.refreshError ?? txError;
    } else if (obligationResult is AuthFailure) {
      obligationStale = true;
      obligationError = snapshot?.refreshError ?? obligationResult.message;
    }
    final productSnapshot = await productFuture;
    if (productSnapshot != null) {
      _productsCached = productSnapshot.items;
    }
    if (!mounted) {
      return;
    }

    try {
      final records = snapshot?.items ?? _records;
      if (records == null) {
        state = DashboardFinanceState(
          isStale: true,
          periodKind: selection.kind,
          periodLabel: selection.label,
          error: txError ?? obligationError,
        );
        return;
      }
      _records = records;
      if (outlookKnown) {
        _commitments = commitments ?? const <BusinessObligation>[];
      }
      _publish(
        session: session,
        records: records,
        commitments: outlookKnown ? commitments : null,
        isStale:
            session.isStale || (snapshot?.isStale ?? true) || obligationStale,
        error: obligationError,
        hitRecordCap:
            snapshot != null &&
            (snapshot.hasMore || snapshot.items.length >= 5000),
      );
    } on FinanceException catch (error) {
      if (!mounted) {
        return;
      }
      if (_records != null) {
        state = state.copyWith(
          loading: false,
          isStale: true,
          error: error.message,
        );
        return;
      }
      state = DashboardFinanceState(
        isStale: true,
        periodKind: selection.kind,
        periodLabel: selection.label,
        error: error.message,
      );
    }
  }

  DashboardPeriodSelection _selection(AppSessionReady session) {
    return DashboardPeriodSelection.resolve(
      kind: _kind,
      nowUtc: DateTime.now().toUtc(),
      zone: BusinessZone.forCountry(session.business.countryCode),
      customStartWall: _customStart,
      customEndWall: _customEnd,
    );
  }

  void _publish({
    required AppSessionReady session,
    required List<BusinessTransaction> records,
    required List<BusinessObligation>? commitments,
    required bool isStale,
    required String? error,
    required bool hitRecordCap,
  }) {
    final now = DateTime.now().toUtc();
    final zone = BusinessZone.forCountry(session.business.countryCode);
    final selection = _selection(session);
    final confirmedRecords =
        records.where((item) => !item.pendingSync).toList();
    final confirmedCommitments =
        commitments?.where((item) => !item.pendingSync).toList();
    final summary = FinancialEngine.summarize(
      entries: confirmedLedgerEntries(confirmedRecords),
      openingCashMinor: session.business.openingBalanceMinor,
      currencyCode: session.business.currencyCode,
      period: selection.period,
      asOf: now,
    );
    final outlook =
        confirmedCommitments == null
            ? null
            : CashOutlookEngine.summarize(
              currentCashMinor: summary.currentCashMinor,
              currencyCode: summary.currencyCode,
              asOf: now,
              zone: zone,
              commitments: confirmedCommitments.map(
                (item) => item.toScheduledCommitment(),
              ),
            );
    final recent = [...confirmedRecords]..sort((a, b) {
      final byDate = b.occurredAt.compareTo(a.occurredAt);
      if (byDate != 0) {
        return byDate;
      }
      return b.id.compareTo(a.id);
    });
    final open =
        confirmedCommitments == null
            ? const <BusinessObligation>[]
            : (confirmedCommitments
                .where((item) => item.status == CommitmentStatus.unpaid)
                .toList()
              ..sort((a, b) => a.dueOn.compareTo(b.dueOn)));
    final overdue = [
      for (final item in open)
        if (item.displayStatus(asOf: now, zone: zone) ==
            ObligationDisplayStatus.overdue)
          item,
    ];
    final upcoming = [
      for (final item in open)
        if (item.displayStatus(asOf: now, zone: zone) ==
            ObligationDisplayStatus.unpaid)
          item,
    ];
    final sparkline = SparklineSeries.dailyTotals(
      entries: confirmedLedgerEntries(confirmedRecords),
      period: selection.period,
      asOf: now,
      types: const {MoneyMovementType.sale},
    );
    final inventory = InventoryInsights.fromProducts(_productsCached);
    final forecast =
        confirmedCommitments == null
            ? null
            : CashForecastEngine.project(
              currentCashMinor: summary.currentCashMinor,
              currencyCode: summary.currencyCode,
              asOf: now,
              zone: zone,
              horizon: _horizon,
              commitments: confirmedCommitments.map(
                (item) => item.toScheduledCommitment(),
              ),
              unpaidSalesMinor: summary.unpaidSalesMinor,
              unpaidExpensesMinor: summary.unpaidExpensesMinor,
              inventoryValueMinor: inventory.estimatedValueMinor,
              hitRecordCap: hitRecordCap,
              skippedMixedCurrencyTransactions: summary.skippedMixedCurrency,
            );
    state = DashboardFinanceState(
      summary: summary,
      outlook: outlook,
      forecastHorizon: _horizon,
      forecast: forecast,
      insights: DashboardInsights.from(
        summary: summary,
        outlook: outlook,
        hitRecordCap: hitRecordCap,
      ),
      recent: recent.take(5).toList(),
      upcoming: upcoming,
      overdue: overdue,
      salesSparkline: sparkline,
      isStale: isStale,
      periodKind: selection.kind,
      periodLabel: selection.label,
      error: error,
      hitRecordCap: hitRecordCap,
    );
  }
}
