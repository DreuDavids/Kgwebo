import '../../authentication/domain/auth_failure.dart';
import '../application/onboarding_repository.dart';
import '../domain/business_profile.dart';
import '../domain/onboarding_draft.dart';

class PreviewOnboardingRepository extends OnboardingRepository {
  PreviewOnboardingRepository();

  static const _previewMessage =
      'Preview and demo modes do not write business records to Supabase.';

  @override
  Future<BusinessProfile?> findOwnedBusiness() async => null;

  @override
  Future<BusinessProfile> save(OnboardingDraft draft) async {
    throw const AuthFailure(_previewMessage);
  }

  @override
  Future<BusinessProfile> updateExisting({
    required String businessId,
    required OnboardingDraft draft,
  }) async {
    throw const AuthFailure(_previewMessage);
  }
}
