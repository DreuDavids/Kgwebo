import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/application/session_controller.dart';
import '../../authentication/domain/app_session.dart';
import '../../authentication/domain/auth_failure.dart';
import '../../onboarding/application/onboarding_repository.dart';
import '../../onboarding/domain/business_profile.dart';
import '../../onboarding/domain/business_snapshot.dart';
import '../../onboarding/domain/onboarding_draft.dart';

class BusinessProfileViewState {
  const BusinessProfileViewState({
    this.loading = false,
    this.refreshing = false,
    this.saving = false,
    this.isPreview = false,
    this.snapshot,
    this.error,
    this.success,
  });

  final bool loading;
  final bool refreshing;
  final bool saving;
  final bool isPreview;
  final BusinessSnapshot? snapshot;
  final String? error;
  final String? success;

  bool get hasBusiness => snapshot != null;

  bool get isStale => snapshot?.isStale ?? false;

  BusinessProfile? get profile => snapshot?.profile;

  BusinessProfileViewState copyWith({
    bool? loading,
    bool? refreshing,
    bool? saving,
    bool? isPreview,
    BusinessSnapshot? snapshot,
    String? error,
    String? success,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearSnapshot = false,
  }) {
    return BusinessProfileViewState(
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      saving: saving ?? this.saving,
      isPreview: isPreview ?? this.isPreview,
      snapshot: clearSnapshot ? null : (snapshot ?? this.snapshot),
      error: clearError ? null : (error ?? this.error),
      success: clearSuccess ? null : (success ?? this.success),
    );
  }
}

final businessProfileControllerProvider = StateNotifierProvider.autoDispose<
  BusinessProfileController,
  BusinessProfileViewState
>((ref) {
  final ownerId = ref.watch(currentOwnerIdProvider);
  final session = ref.read(appSessionProvider);
  return BusinessProfileController(
    ownerId: ownerId,
    session: session,
    repository: ref.watch(onboardingRepositoryProvider),
    onConfirmed: (profile) {
      ref
          .read(sessionControllerProvider.notifier)
          .applyConfirmedBusiness(profile);
    },
    onSessionExpired:
        () => ref.read(sessionControllerProvider.notifier).signOut(),
  );
});

class BusinessProfileController
    extends StateNotifier<BusinessProfileViewState> {
  BusinessProfileController({
    required this.ownerId,
    required AppSession session,
    required OnboardingRepository repository,
    required void Function(BusinessProfile profile) onConfirmed,
    required Future<void> Function() onSessionExpired,
  }) : _repository = repository,
       _onConfirmed = onConfirmed,
       _onSessionExpired = onSessionExpired,
       super(_initial(session, ownerId)) {
    if (!state.isPreview) {
      refresh();
    }
  }

  final String? ownerId;
  final OnboardingRepository _repository;
  final void Function(BusinessProfile profile) _onConfirmed;
  final Future<void> Function() _onSessionExpired;

  static BusinessProfileViewState _initial(
    AppSession session,
    String? ownerId,
  ) {
    return switch (session) {
      AppSessionPreview() => const BusinessProfileViewState(isPreview: true),
      AppSessionReady(:final business, :final isStale, :final user)
          when ownerId != null && business.belongsTo(user.id) =>
        BusinessProfileViewState(
          snapshot:
              isStale
                  ? BusinessSnapshot.stale(
                    profile: business,
                    refreshError:
                        'Showing the last saved copy. Check your connection to refresh.',
                  )
                  : BusinessSnapshot.remote(business),
          refreshing: true,
        ),
      _ => const BusinessProfileViewState(loading: true),
    };
  }

  Future<void> refresh() async {
    if (state.isPreview) {
      return;
    }
    if (ownerId == null) {
      state = const BusinessProfileViewState(
        error: 'Sign in to view your business profile.',
      );
      return;
    }
    state = state.copyWith(
      loading: !state.hasBusiness,
      refreshing: state.hasBusiness,
      clearError: true,
      clearSuccess: true,
    );
    try {
      final snapshot = await _repository.loadOwnedBusiness();
      if (!mounted) {
        return;
      }
      if (snapshot == null) {
        state = const BusinessProfileViewState(
          error:
              'No business profile was found. If this is unexpected, retry or finish setup.',
        );
        return;
      }
      if (!snapshot.profile.belongsTo(ownerId!)) {
        state = const BusinessProfileViewState(
          error: 'This business does not belong to the signed-in account.',
        );
        return;
      }
      if (snapshot.isConfirmedRemote) {
        _onConfirmed(snapshot.profile);
      }
      state = BusinessProfileViewState(snapshot: snapshot);
    } on AuthFailure catch (error) {
      await _handleFailure(error);
    }
  }

  Future<void> save(OnboardingDraft draft) async {
    if (state.saving) {
      return;
    }
    final current = state.profile;
    if (current == null || ownerId == null) {
      state = state.copyWith(
        error: 'The business profile could not be loaded. Retry and try again.',
      );
      return;
    }
    if (!current.belongsTo(ownerId!)) {
      state = state.copyWith(
        error: 'This business does not belong to the signed-in account.',
      );
      return;
    }
    state = state.copyWith(saving: true, clearError: true, clearSuccess: true);
    try {
      final updated = await _repository.updateExisting(
        businessId: current.id,
        draft: draft,
      );
      if (!mounted) {
        return;
      }
      if (updated.id != current.id || !updated.belongsTo(ownerId!)) {
        state = state.copyWith(
          saving: false,
          error:
              'The server returned a different business than the one being edited.',
        );
        return;
      }
      _onConfirmed(updated);
      state = BusinessProfileViewState(
        snapshot: BusinessSnapshot.remote(updated),
        success: 'Business profile saved.',
      );
    } on AuthFailure catch (error) {
      await _handleFailure(error);
    }
  }

  Future<void> _handleFailure(AuthFailure error) async {
    if (error.code == 'session_expired') {
      await _onSessionExpired();
      if (!mounted) {
        return;
      }
      state = const BusinessProfileViewState(
        error: 'You were signed out. Sign in again.',
      );
      return;
    }
    if (!mounted) {
      return;
    }
    final cached = state.snapshot;
    if (cached != null) {
      state = state.copyWith(
        loading: false,
        refreshing: false,
        saving: false,
        snapshot: BusinessSnapshot.stale(
          profile: cached.profile,
          refreshError: error.message,
        ),
        error: error.message,
        clearSuccess: true,
      );
      return;
    }
    state = BusinessProfileViewState(error: error.message);
  }
}
