import '../domain/business_obligation.dart';
import '../domain/obligation_draft.dart';
import '../domain/obligation_snapshot.dart';

abstract class ObligationRepository {
  Future<ObligationListSnapshot> listAllConfirmed({
    required String ownerId,
    required String businessId,
  });

  Future<BusinessObligation?> findById({
    required String ownerId,
    required String businessId,
    required String obligationId,
  });

  Future<BusinessObligation> create({
    required String ownerId,
    required String businessId,
    required String currencyCode,
    required ObligationDraft draft,
  });

  Future<BusinessObligation> update({
    required String ownerId,
    required String businessId,
    required String currencyCode,
    required ObligationDraft draft,
  });

  Future<void> delete({
    required String ownerId,
    required String businessId,
    required String obligationId,
  });
}
