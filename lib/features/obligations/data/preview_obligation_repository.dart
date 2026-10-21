import '../../authentication/domain/auth_failure.dart';
import '../application/obligation_repository.dart';
import '../domain/business_obligation.dart';
import '../domain/obligation_draft.dart';
import '../domain/obligation_snapshot.dart';

class PreviewObligationRepository implements ObligationRepository {
  static const _previewMessage =
      'Preview and demo modes do not write commitments to Supabase.';

  @override
  Future<ObligationListSnapshot> listAllConfirmed({
    required String ownerId,
    required String businessId,
  }) async {
    return const ObligationListSnapshot(
      items: [],
      origin: ObligationDataOrigin.remote,
    );
  }

  @override
  Future<BusinessObligation?> findById({
    required String ownerId,
    required String businessId,
    required String obligationId,
  }) async {
    return null;
  }

  @override
  Future<BusinessObligation> create({
    required String ownerId,
    required String businessId,
    required String currencyCode,
    required ObligationDraft draft,
  }) async {
    throw const AuthFailure(_previewMessage);
  }

  @override
  Future<BusinessObligation> update({
    required String ownerId,
    required String businessId,
    required String currencyCode,
    required ObligationDraft draft,
  }) async {
    throw const AuthFailure(_previewMessage);
  }

  @override
  Future<void> delete({
    required String ownerId,
    required String businessId,
    required String obligationId,
  }) async {
    throw const AuthFailure(_previewMessage);
  }
}
