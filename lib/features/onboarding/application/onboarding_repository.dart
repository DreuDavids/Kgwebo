import '../domain/business_profile.dart';
import '../domain/business_snapshot.dart';
import '../domain/onboarding_draft.dart';

abstract class OnboardingRepository {
  Future<BusinessProfile?> findOwnedBusiness();

  /// Cache-aware load. Default implementation is a confirmed remote read.
  Future<BusinessSnapshot?> loadOwnedBusiness() async {
    final profile = await findOwnedBusiness();
    if (profile == null) {
      return null;
    }
    return BusinessSnapshot.remote(profile);
  }

  Future<BusinessProfile> save(OnboardingDraft draft);

  /// Updates the existing row identified by [businessId]. Must not insert.
  Future<BusinessProfile> updateExisting({
    required String businessId,
    required OnboardingDraft draft,
  });
}
