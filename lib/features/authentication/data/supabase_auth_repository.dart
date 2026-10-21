import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/logging/app_logger.dart';
import '../application/auth_repository.dart';
import '../domain/auth_change.dart';
import '../domain/auth_failure.dart';
import '../domain/auth_user.dart' as kgwebo;
import '../domain/sign_up_result.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  @override
  Stream<AuthChange> watch() {
    return _auth.onAuthStateChange.map(_mapChange);
  }

  @override
  Future<kgwebo.AuthUser?> currentUser() async {
    try {
      final session = _auth.currentSession;
      return _mapUser(session?.user);
    } on AuthException catch (error) {
      throw _fromAuthException(error);
    }
  }

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signUp(
        email: email.trim(),
        password: password,
      );
      final user = response.user;
      if (response.session != null && user != null) {
        return SignUpSessionCreated(_mustMapUser(user));
      }
      return SignUpConfirmationRequired(email.trim());
    } on AuthException catch (error) {
      throw _fromAuthException(error);
    } catch (error) {
      throw AuthFailure.fromMessage('$error');
    }
  }

  @override
  Future<kgwebo.AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw const AuthFailure(
          'Sign-in did not return a user. Please try again.',
        );
      }
      return _mustMapUser(user);
    } on AuthException catch (error) {
      throw _fromAuthException(error);
    } catch (error) {
      if (error is AuthFailure) {
        rethrow;
      }
      throw AuthFailure.fromMessage('$error');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on AuthException catch (error) {
      throw _fromAuthException(error);
    }
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    try {
      await _auth.resetPasswordForEmail(email.trim());
    } on AuthException catch (error) {
      throw _fromAuthException(error);
    } catch (error) {
      throw AuthFailure.fromMessage('$error');
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (error) {
      throw _fromAuthException(error);
    } catch (error) {
      throw AuthFailure.fromMessage('$error');
    }
  }

  @override
  Future<void> resendSignupEmail(String email) async {
    try {
      await _auth.resend(type: OtpType.signup, email: email.trim());
    } on AuthException catch (error) {
      throw _fromAuthException(error);
    } catch (error) {
      throw AuthFailure.fromMessage('$error');
    }
  }

  @override
  Future<void> verifySignupOtp({required String email, required String token}) {
    return _verifyEmailOtp(email: email, token: token, type: OtpType.signup);
  }

  @override
  Future<void> verifyRecoveryOtp({
    required String email,
    required String token,
  }) {
    return _verifyEmailOtp(email: email, token: token, type: OtpType.recovery);
  }

  Future<void> _verifyEmailOtp({
    required String email,
    required String token,
    required OtpType type,
  }) async {
    try {
      final response = await _auth.verifyOTP(
        email: email.trim(),
        token: token.trim(),
        type: type,
      );
      if (response.session == null && response.user == null) {
        throw const AuthFailure(
          'That code is incorrect or has expired. Request a new one.',
        );
      }
    } on AuthException catch (error) {
      throw _fromAuthException(error);
    } catch (error) {
      if (error is AuthFailure) {
        rethrow;
      }
      throw AuthFailure.fromMessage('$error');
    }
  }

  AuthChange _mapChange(AuthState state) {
    final user = _mapUser(state.session?.user);
    final kind = switch (state.event) {
      AuthChangeEvent.initialSession => AuthChangeKind.initial,
      AuthChangeEvent.signedIn => AuthChangeKind.signedIn,
      AuthChangeEvent.signedOut => AuthChangeKind.signedOut,
      AuthChangeEvent.passwordRecovery => AuthChangeKind.passwordRecovery,
      AuthChangeEvent.tokenRefreshed => AuthChangeKind.tokenRefreshed,
      AuthChangeEvent.userUpdated => AuthChangeKind.userUpdated,
      // ignore: deprecated_member_use
      AuthChangeEvent.userDeleted => AuthChangeKind.userDeleted,
      AuthChangeEvent.mfaChallengeVerified => AuthChangeKind.userUpdated,
    };
    return AuthChange(kind: kind, user: user);
  }

  kgwebo.AuthUser? _mapUser(User? user) {
    if (user == null) {
      return null;
    }
    return _mustMapUser(user);
  }

  kgwebo.AuthUser _mustMapUser(User user) {
    return kgwebo.AuthUser(
      id: user.id,
      email: user.email,
      emailConfirmed: user.emailConfirmedAt != null,
    );
  }

  AuthFailure _fromAuthException(AuthException error) {
    AppLogger.warning('Auth error code=${error.code ?? 'unknown'}');
    return AuthFailure.fromCode(error.code, fallback: error.message);
  }
}
