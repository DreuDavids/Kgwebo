import 'dart:async';

import 'package:kgwebo/features/authentication/application/auth_repository.dart';
import 'package:kgwebo/features/authentication/domain/auth_change.dart';
import 'package:kgwebo/features/authentication/domain/auth_failure.dart';
import 'package:kgwebo/features/authentication/domain/auth_user.dart';
import 'package:kgwebo/features/authentication/domain/sign_up_result.dart';
import 'package:kgwebo/features/onboarding/application/onboarding_repository.dart';
import 'package:kgwebo/features/onboarding/domain/business_profile.dart';
import 'package:kgwebo/features/onboarding/domain/onboarding_draft.dart';
import 'package:kgwebo/core/validation/onboarding_validators.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.user, this.requireEmailConfirmation = false});

  AuthUser? user;
  bool requireEmailConfirmation;
  AuthFailure? nextError;
  int signInCalls = 0;
  int signUpCalls = 0;
  int signOutCalls = 0;
  int resetCalls = 0;
  int updatePasswordCalls = 0;
  final _controller = StreamController<AuthChange>.broadcast();

  void emit(AuthChange change) => _controller.add(change);

  @override
  Stream<AuthChange> watch() async* {
    yield AuthChange(kind: AuthChangeKind.initial, user: user);
    yield* _controller.stream;
  }

  @override
  Future<AuthUser?> currentUser() async => user;

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
  }) async {
    signUpCalls += 1;
    _throwIfNeeded();
    if (requireEmailConfirmation) {
      return SignUpConfirmationRequired(email.trim());
    }
    user = AuthUser(id: 'user-1', email: email.trim(), emailConfirmed: true);
    emit(AuthChange(kind: AuthChangeKind.signedIn, user: user));
    return SignUpSessionCreated(user!);
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    signInCalls += 1;
    _throwIfNeeded();
    user = AuthUser(id: 'user-1', email: email.trim(), emailConfirmed: true);
    emit(AuthChange(kind: AuthChangeKind.signedIn, user: user));
    return user!;
  }

  @override
  Future<void> signOut() async {
    signOutCalls += 1;
    _throwIfNeeded();
    user = null;
    emit(const AuthChange(kind: AuthChangeKind.signedOut));
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    resetCalls += 1;
    _throwIfNeeded();
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    updatePasswordCalls += 1;
    _throwIfNeeded();
  }

  @override
  Future<void> resendSignupEmail(String email) async {
    _throwIfNeeded();
  }

  void _throwIfNeeded() {
    final error = nextError;
    nextError = null;
    if (error != null) {
      throw error;
    }
  }
}

class FakeOnboardingRepository extends OnboardingRepository {
  FakeOnboardingRepository({this.business, this.ownerId = 'user-1'});

  BusinessProfile? business;
  String ownerId;
  int saveCalls = 0;
  int updateCalls = 0;
  int findCalls = 0;
  AuthFailure? nextError;
  AuthFailure? findError;

  @override
  Future<BusinessProfile?> findOwnedBusiness() async {
    findCalls += 1;
    if (findError != null) {
      throw findError!;
    }
    final current = business;
    if (current == null || current.ownerId != ownerId) {
      return null;
    }
    return current;
  }

  @override
  Future<BusinessProfile> save(OnboardingDraft draft) async {
    saveCalls += 1;
    final error = nextError;
    nextError = null;
    if (error != null) {
      throw error;
    }
    business = BusinessProfile(
      id: business?.id ?? 'biz-1',
      ownerId: ownerId,
      name: draft.name.trim(),
      businessType: draft.businessType.trim(),
      countryCode: draft.countryCode,
      currencyCode: draft.currencyCode,
      openingBalanceMinor: parseOpeningBalanceMinor(draft.openingCashText),
      description:
          draft.description.trim().isEmpty ? null : draft.description.trim(),
      startedOn: draft.startedOn,
      contactPhone:
          draft.contactPhone.trim().isEmpty ? null : draft.contactPhone.trim(),
    );
    return business!;
  }

  @override
  Future<BusinessProfile> updateExisting({
    required String businessId,
    required OnboardingDraft draft,
  }) async {
    updateCalls += 1;
    final error = nextError;
    nextError = null;
    if (error != null) {
      throw error;
    }
    final current = business;
    if (current == null ||
        current.id != businessId ||
        current.ownerId != ownerId) {
      throw const AuthFailure(
        'Could not update this business. It may not exist or you may not own it.',
      );
    }
    business = current.copyWith(
      name: draft.name.trim(),
      businessType: draft.businessType.trim(),
      countryCode: draft.countryCode,
      currencyCode: draft.currencyCode,
      openingBalanceMinor: parseOpeningBalanceMinor(draft.openingCashText),
      description:
          draft.description.trim().isEmpty ? null : draft.description.trim(),
      startedOn: draft.startedOn,
      contactPhone:
          draft.contactPhone.trim().isEmpty ? null : draft.contactPhone.trim(),
      clearDescription: draft.description.trim().isEmpty,
      clearStartedOn: draft.startedOn == null,
      clearContactPhone: draft.contactPhone.trim().isEmpty,
    );
    return business!;
  }
}
