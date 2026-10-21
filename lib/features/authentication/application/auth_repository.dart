import '../domain/auth_change.dart';
import '../domain/auth_user.dart';
import '../domain/sign_up_result.dart';

abstract class AuthRepository {
  Stream<AuthChange> watch();

  Future<AuthUser?> currentUser();

  Future<SignUpResult> signUp({
    required String email,
    required String password,
  });

  Future<AuthUser> signIn({required String email, required String password});

  Future<void> signOut();

  Future<void> requestPasswordReset(String email);

  Future<void> updatePassword(String newPassword);

  Future<void> resendSignupEmail(String email);
}
