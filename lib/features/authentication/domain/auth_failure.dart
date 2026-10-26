import '../../../core/logging/app_logger.dart';

class AuthFailure implements Exception {
  const AuthFailure(
    this.message, {
    this.code,
    this.isRetryable = false,
    this.requiresEmailConfirmation = false,
  });

  final String message;
  final String? code;
  final bool isRetryable;
  final bool requiresEmailConfirmation;

  const AuthFailure.network()
    : message = 'Check your connection and try again.',
      code = 'network',
      isRetryable = true,
      requiresEmailConfirmation = false;

  factory AuthFailure.fromCode(String? code, {String? fallback}) {
    final normalized = (code ?? '').trim().toLowerCase();
    return switch (normalized) {
      'invalid_credentials' || 'invalid_grant' => const AuthFailure(
        'Email or password is incorrect.',
        code: 'invalid_credentials',
      ),
      'email_not_confirmed' => const AuthFailure(
        'Confirm your email address before signing in. Check your inbox for a 6-character code from Kgwebo.',
        code: 'email_not_confirmed',
        requiresEmailConfirmation: true,
      ),
      'user_already_exists' || 'email_exists' => const AuthFailure(
        'An account with this email already exists. Sign in or reset your password.',
        code: 'user_already_exists',
      ),
      'over_email_send_rate_limit' ||
      'over_request_rate_limit' => const AuthFailure(
        'Please wait a moment before requesting another email.',
        code: 'over_email_send_rate_limit',
        isRetryable: true,
      ),
      'otp_expired' || 'token_expired' => const AuthFailure(
        'That code is incorrect or has expired. Request a new one.',
        code: 'otp_expired',
        isRetryable: true,
      ),
      'weak_password' => const AuthFailure(
        'Choose a stronger password.',
        code: 'weak_password',
      ),
      'same_password' => const AuthFailure(
        'Choose a password you have not used before.',
        code: 'same_password',
      ),
      'session_not_found' || 'session_expired' => const AuthFailure(
        'You were signed out. Sign in again.',
        code: 'session_expired',
      ),
      _ => AuthFailure._unmapped(normalized, fallback),
    };
  }

  factory AuthFailure.fromMessage(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('invalid login') ||
        lower.contains('invalid_credentials')) {
      return AuthFailure.fromCode('invalid_credentials');
    }
    if (lower.contains('email not confirmed')) {
      return AuthFailure.fromCode('email_not_confirmed');
    }
    if (lower.contains('expired') &&
        (lower.contains('otp') || lower.contains('token'))) {
      return AuthFailure.fromCode('otp_expired');
    }
    if (lower.contains('already registered') ||
        lower.contains('already exists')) {
      return AuthFailure.fromCode('user_already_exists');
    }
    if (lower.contains('socket') ||
        lower.contains('network') ||
        lower.contains('failed host lookup') ||
        lower.contains('timeout')) {
      return AuthFailure.network();
    }
    if (lower.contains('enough stock')) {
      return const AuthFailure('There is not enough stock for this movement.');
    }
    return const AuthFailure(
      'Something went wrong. Please try again.',
      isRetryable: true,
    );
  }

  factory AuthFailure._unmapped(String code, String? fallback) {
    if (fallback != null && fallback.trim().isNotEmpty) {
      AppLogger.warning('Unmapped auth failure code=$code');
    }
    return AuthFailure(
      'Something went wrong. Please try again.',
      code: code.isEmpty ? null : code,
      isRetryable: true,
    );
  }

  @override
  String toString() => message;
}
