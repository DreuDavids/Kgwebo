import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/finance/business_calendar.dart';
import '../../../core/finance/cash_outlook.dart';
import '../../../core/finance/dashboard_insights.dart';
import '../../../core/finance/dashboard_period.dart';
import '../../../core/finance/finance_exception.dart';
import '../../../core/finance/financial_engine.dart';
import '../../../core/finance/financial_summary.dart';
import '../../../core/finance/ledger_entry.dart';
import '../../../core/finance/sparkline_series.dart';
import '../../authentication/application/session_controller.dart';
import '../../authentication/domain/app_session.dart';
import '../../authentication/domain/auth_failure.dart';
import '../../obligations/application/obligation_repository.dart';
import '../../obligations/application/obligation_tick.dart';
import '../../obligations/domain/business_obligation.dart';
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
  );
  ref.listen<int>(transactionTickProvider, (_, __) {
    controller.refresh();
  });
  ref.listen<int>(obligationTickProvider, (_, __) {
    controller.refresh();
  });
  return controller;
});

class DashboardFinanceController extends StateNotifier<DashboardFinanceState> {
  DashboardFinanceController({
    required AppSession session,
    required TransactionRepository transactions,
    required ObligationRepository obligations,
  }) : _session = session,
       _transactions = transactions,
       _obligations = obligations,
       super(const DashboardFinanceState(loading: true)) {
    _load();
  }

  final AppSession _session;
  final TransactionRepository _transactions;
  final ObligationRepository _obligations;

  DashboardPeriodKind _kind = DashboardPeriodKind.thisMonth;
  DateTime? _customStart;
  DateTime? _customEnd;
  List<BusinessTransaction>? _records;
  List<BusinessObligation>? _commitments;

  Future<void> refresh() => _load();

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
      isStale: session.isStale,
      clearError: true,
    );

    try {
      final snapshot = await _transactions.listAllConfirmed(
        ownerId: session.user.id,
        businessId: session.business.id,
      );
      var commitments = _commitments;
      var outlookKnown = commitments != null;
      var obligationError = snapshot.refreshError;
      var obligationStale = snapshot.isStale;
      try {
        final obligationSnapshot = await _obligations.listAllConfirmed(
          ownerId: session.user.id,
          businessId: session.business.id,
        );
        commitments = obligationSnapshot.items;
        outlookKnown = true;
        obligationStale = obligationSnapshot.isStale;
        obligationError =
            snapshot.refreshError ?? obligationSnapshot.refreshError;
      } on AuthFailure catch (error) {
        obligationStale = true;
        obligationError = snapshot.refreshError ?? error.message;
      }
      if (!mounted) {
        return;
      }
      _records = snapshot.items;
      if (outlookKnown) {
        _commitments = commitments ?? const <BusinessObligation>[];
      }
      _publish(
        session: session,
        records: snapshot.items,
        commitments: outlookKnown ? commitments : null,
        isStale: session.isStale || snapshot.isStale || obligationStale,
        error: obligationError,
        hitRecordCap: snapshot.hasMore || snapshot.items.length >= 5000,
      );
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }
      final records = _records;
      if (records != null) {
        _publish(
          session: session,
          records: records,
          commitments: _commitments,
          isStale: true,
          error: error.message,
          hitRecordCap: state.hitRecordCap,
        );
        return;
      }
      state = DashboardFinanceState(
        isStale: true,
        periodKind: selection.kind,
        periodLabel: selection.label,
        error: error.message,
      );
    } on FinanceException catch (error) {
      if (!mounted) {
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
    final summary = FinancialEngine.summarize(
      entries: records.map((item) => item.toLedgerEntry()),
      openingCashMinor: session.business.openingBalanceMinor,
      currencyCode: session.business.currencyCode,
      period: selection.period,
      asOf: now,
    );
    final outlook =
        commitments == null
            ? null
            : CashOutlookEngine.summarize(
              currentCashMinor: summary.currentCashMinor,
              currencyCode: summary.currencyCode,
              asOf: now,
              zone: zone,
              commitments: commitments.map(
                (item) => item.toScheduledCommitment(),
              ),
            );
    final recent = [...records]..sort((a, b) {
      final byDate = b.occurredAt.compareTo(a.occurredAt);
      if (byDate != 0) {
        return byDate;
      }
      return b.id.compareTo(a.id);
    });
    final open =
        commitments == null
            ? const <BusinessObligation>[]
            : (commitments
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
      entries: records.map((item) => item.toLedgerEntry()),
      period: selection.period,
      asOf: now,
      types: const {MoneyMovementType.sale},
    );
    state = DashboardFinanceState(
      summary: summary,
      outlook: outlook,
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
