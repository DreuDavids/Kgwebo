import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/finance/business_calendar.dart';
import '../../../core/finance/dashboard_period.dart';
import '../../../core/finance/finance_exception.dart';
import '../../../core/sync/pending_presentation.dart';
import '../../authentication/application/session_controller.dart';
import '../../authentication/domain/app_session.dart';
import '../../authentication/domain/auth_failure.dart';
import '../../transactions/application/transaction_repository.dart';
import '../../transactions/application/transaction_tick.dart';
import '../../transactions/domain/business_transaction.dart';
import '../domain/report_document.dart';
import 'report_builder.dart';
import 'report_exporter.dart';
import 'report_file_name.dart';
import 'report_pdf.dart';

enum ReportExportStatus { idle, exporting, success, error }

class ReportViewState {
  const ReportViewState({
    this.loading = false,
    this.document,
    this.isStale = false,
    this.isPreview = false,
    this.periodKind = DashboardPeriodKind.thisMonth,
    this.periodLabel = '',
    this.error,
    this.hitRecordCap = false,
    this.exportStatus = ReportExportStatus.idle,
    this.exportError,
  });

  final bool loading;
  final ReportDocument? document;
  final bool isStale;
  final bool isPreview;
  final DashboardPeriodKind periodKind;
  final String periodLabel;
  final String? error;
  final bool hitRecordCap;
  final ReportExportStatus exportStatus;
  final String? exportError;

  ReportViewState copyWith({
    bool? loading,
    ReportDocument? document,
    bool? isStale,
    bool? isPreview,
    DashboardPeriodKind? periodKind,
    String? periodLabel,
    String? error,
    bool? hitRecordCap,
    ReportExportStatus? exportStatus,
    String? exportError,
    bool clearError = false,
    bool clearDocument = false,
    bool clearExportError = false,
  }) {
    return ReportViewState(
      loading: loading ?? this.loading,
      document: clearDocument ? null : (document ?? this.document),
      isStale: isStale ?? this.isStale,
      isPreview: isPreview ?? this.isPreview,
      periodKind: periodKind ?? this.periodKind,
      periodLabel: periodLabel ?? this.periodLabel,
      error: clearError ? null : (error ?? this.error),
      hitRecordCap: hitRecordCap ?? this.hitRecordCap,
      exportStatus: exportStatus ?? this.exportStatus,
      exportError: clearExportError ? null : (exportError ?? this.exportError),
    );
  }
}

final reportExporterProvider = Provider<ReportExporter>((ref) {
  return DeviceReportExporter();
});

final reportControllerProvider =
    StateNotifierProvider.autoDispose<ReportController, ReportViewState>((ref) {
      final controller = ReportController(
        session: ref.watch(appSessionProvider),
        transactions: ref.watch(transactionRepositoryProvider),
        exporter: ref.watch(reportExporterProvider),
      );
      ref.listen<int>(transactionTickProvider, (_, __) {
        controller.refresh();
      });
      ref.listen<int>(syncTickProvider, (_, __) {
        controller.refresh();
      });
      return controller;
    });

class ReportController extends StateNotifier<ReportViewState> {
  ReportController({
    required AppSession session,
    required TransactionRepository transactions,
    required ReportExporter exporter,
    DateTime Function()? clock,
  }) : _session = session,
       _transactions = transactions,
       _exporter = exporter,
       _clock = clock ?? DateTime.now,
       super(const ReportViewState(loading: true)) {
    _load();
  }

  final AppSession _session;
  final TransactionRepository _transactions;
  final ReportExporter _exporter;
  final DateTime Function() _clock;

  DashboardPeriodKind _kind = DashboardPeriodKind.thisMonth;
  DateTime? _customStart;
  DateTime? _customEnd;
  List<BusinessTransaction>? _records;

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
    final session = _session;
    if (records != null && session is AppSessionReady) {
      _publish(
        session: session,
        records: records,
        isStale: state.isStale,
        error: state.error,
        hitRecordCap: state.hitRecordCap,
      );
      return;
    }
    _load();
  }

  Future<void> exportPdf() async {
    final document = state.document;
    if (document == null ||
        state.exportStatus == ReportExportStatus.exporting) {
      return;
    }
    state = state.copyWith(
      exportStatus: ReportExportStatus.exporting,
      clearExportError: true,
    );
    try {
      final bytes = await ReportPdf.build(document);
      await _exporter.share(
        bytes: bytes,
        filename: ReportFileName.pdf(
          businessName: document.businessName,
          periodLabel: document.periodLabel,
        ),
      );
      if (!mounted) {
        return;
      }
      state = state.copyWith(exportStatus: ReportExportStatus.success);
    } on ReportPdfException catch (error) {
      if (!mounted) {
        return;
      }
      state = state.copyWith(
        exportStatus: ReportExportStatus.error,
        exportError: error.message,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      state = state.copyWith(
        exportStatus: ReportExportStatus.error,
        exportError: 'Could not share the PDF. Try again from this device.',
      );
    }
  }

  Future<void> _load() async {
    final session = _session;
    if (session is AppSessionPreview) {
      state = const ReportViewState(isPreview: true);
      return;
    }
    if (session is! AppSessionReady) {
      state = const ReportViewState();
      return;
    }

    final selection = _selection(session);
    state = state.copyWith(
      loading: true,
      periodKind: selection.kind,
      periodLabel: selection.label,
      clearError: true,
    );

    try {
      final snapshot = await _transactions.listAllConfirmed(
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
            isStale: true,
            error: null,
            hitRecordCap: cached.hasMore || cached.items.length >= 5000,
          );
        },
      );
      if (!mounted) {
        return;
      }
      _records = snapshot.items;
      _publish(
        session: session,
        records: snapshot.items,
        isStale: session.isStale || snapshot.isStale,
        error: snapshot.refreshError,
        hitRecordCap: snapshot.hasMore || snapshot.items.length >= 5000,
      );
    } on AuthFailure catch (error) {
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
      state = ReportViewState(
        isStale: true,
        periodKind: selection.kind,
        periodLabel: selection.label,
        error: error.message,
      );
    } on FinanceException catch (error) {
      if (!mounted) {
        return;
      }
      state = ReportViewState(
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
      nowUtc: _clock().toUtc(),
      zone: BusinessZone.forCountry(session.business.countryCode),
      customStartWall: _customStart,
      customEndWall: _customEnd,
    );
  }

  void _publish({
    required AppSessionReady session,
    required List<BusinessTransaction> records,
    required bool isStale,
    required String? error,
    required bool hitRecordCap,
  }) {
    final selection = _selection(session);
    final confirmed = records.where((item) => !item.pendingSync).toList();
    final document = ReportBuilder.build(
      business: session.business,
      entries: confirmedLedgerEntries(confirmed),
      period: selection.period,
      periodLabel: selection.label,
      generatedAt: _clock().toUtc(),
      isStale: isStale,
      historyIncomplete: hitRecordCap,
    );
    state = ReportViewState(
      document: document,
      isStale: isStale,
      periodKind: selection.kind,
      periodLabel: selection.label,
      error: error,
      hitRecordCap: hitRecordCap,
      exportStatus: ReportExportStatus.idle,
    );
  }
}
