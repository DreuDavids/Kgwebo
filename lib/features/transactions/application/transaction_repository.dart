import '../../../core/finance/business_calendar.dart';
import '../domain/business_transaction.dart';
import '../domain/transaction_draft.dart';
import '../domain/transaction_query.dart';
import '../domain/transaction_snapshot.dart';

abstract class TransactionRepository {
  Future<TransactionListSnapshot> list({
    required String ownerId,
    required String businessId,
    TransactionQuery query = const TransactionQuery(),
  });

  Future<List<BusinessTransaction>> listConfirmedInRange({
    required String ownerId,
    required String businessId,
    required ReportingPeriod period,
  });

  /// Confirmed rows used for cash and period totals. Capped; never mixed
  /// across owners or businesses.
  ///
  /// [onLocalCache] is invoked with owner-scoped Drift rows, if any, before
  /// the method waits on the network. It must not be treated as current
  /// server-confirmed data.
  Future<TransactionListSnapshot> listAllConfirmed({
    required String ownerId,
    required String businessId,
    void Function(TransactionListSnapshot cached)? onLocalCache,
  });

  Future<BusinessTransaction?> findById({
    required String ownerId,
    required String businessId,
    required String transactionId,
  });

  Future<BusinessTransaction> create({
    required String ownerId,
    required String businessId,
    required String currencyCode,
    required TransactionDraft draft,
  });

  Future<BusinessTransaction> update({
    required String ownerId,
    required String businessId,
    required String currencyCode,
    required TransactionDraft draft,
  });

  Future<void> delete({
    required String ownerId,
    required String businessId,
    required String transactionId,
  });
}
