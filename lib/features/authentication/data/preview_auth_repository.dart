import '../../../app/config/app_environment.dart';
import '../application/auth_repository.dart';
import '../domain/auth_change.dart';
import '../domain/auth_failure.dart';
import '../domain/auth_user.dart';
import '../domain/sign_up_result.dart';

/// Used for labelled demo and local preview. Never talks to Supabase.
class PreviewAuthRepository implements AuthRepository {
  PreviewAuthRepository(this.mode);

  final AppRuntimeMode mode;

  String get _blocked {
    return mode == AppRuntimeMode.demo
        ? 'Demo mode does not use real accounts.'
        : 'Local preview has no backend session.';
  }

  @override
  Stream<AuthChange> watch() => const Stream.empty();

  @override
  Future<AuthUser?> currentUser() async => null;

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
  }) async {
    throw AuthFailure(_blocked);
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    throw AuthFailure(_blocked);
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> requestPasswordReset(String email) async {
    throw AuthFailure(_blocked);
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    throw AuthFailure(_blocked);
  }

  @override
  Future<void> resendSignupEmail(String email) async {
    throw AuthFailure(_blocked);
  }

  @override
  Future<void> verifySignupOtp({
    required String email,
    required String token,
  }) async {
    throw AuthFailure(_blocked);
  }

  @override
  Future<void> verifyRecoveryOtp({
    required String email,
    required String token,
  }) async {
    throw AuthFailure(_blocked);
  }
}
