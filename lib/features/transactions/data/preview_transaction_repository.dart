import '../../../core/finance/business_calendar.dart';
import '../../authentication/domain/auth_failure.dart';
import '../application/transaction_repository.dart';
import '../domain/business_transaction.dart';
import '../domain/transaction_draft.dart';
import '../domain/transaction_query.dart';
import '../domain/transaction_snapshot.dart';

class PreviewTransactionRepository implements TransactionRepository {
  static const _previewMessage =
      'Preview and demo modes do not write transactions to Supabase.';

  @override
  Future<TransactionListSnapshot> list({
    required String ownerId,
    required String businessId,
    TransactionQuery query = const TransactionQuery(),
  }) async {
    return const TransactionListSnapshot(
      items: [],
      origin: TransactionDataOrigin.remote,
    );
  }

  @override
  Future<List<BusinessTransaction>> listConfirmedInRange({
    required String ownerId,
    required String businessId,
    required ReportingPeriod period,
  }) async {
    return const [];
  }

  @override
  Future<TransactionListSnapshot> listAllConfirmed({
    required String ownerId,
    required String businessId,
  }) async {
    return const TransactionListSnapshot(
      items: [],
      origin: TransactionDataOrigin.remote,
    );
  }

  @override
  Future<BusinessTransaction?> findById({
    required String ownerId,
    required String businessId,
    required String transactionId,
  }) async {
    return null;
  }

  @override
  Future<BusinessTransaction> create({
    required String ownerId,
    required String businessId,
    required String currencyCode,
    required TransactionDraft draft,
  }) async {
    throw const AuthFailure(_previewMessage);
  }

  @override
  Future<BusinessTransaction> update({
    required String ownerId,
    required String businessId,
    required String currencyCode,
    required TransactionDraft draft,
  }) async {
    throw const AuthFailure(_previewMessage);
  }

  @override
  Future<void> delete({
    required String ownerId,
    required String businessId,
    required String transactionId,
  }) async {
    throw const AuthFailure(_previewMessage);
  }
}
