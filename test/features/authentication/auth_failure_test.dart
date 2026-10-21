import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/features/authentication/domain/auth_failure.dart';

void main() {
  test(
    'maps known auth codes to user-facing copy without leaking internals',
    () {
      expect(
        AuthFailure.fromCode('invalid_credentials').message,
        'Email or password is incorrect.',
      );
      expect(
        AuthFailure.fromCode('email_not_confirmed').message.toLowerCase(),
        contains('confirm'),
      );
      expect(
        AuthFailure.fromCode('user_already_exists').message,
        contains('already'),
      );
      expect(
        AuthFailure.fromCode('over_email_send_rate_limit').message,
        contains('wait'),
      );
      expect(
        AuthFailure.fromCode('otp_expired').message.toLowerCase(),
        contains('expired'),
      );
    },
  );

  test('network failures are retryable', () {
    const failure = AuthFailure.network();
    expect(failure.isRetryable, isTrue);
    expect(failure.message, contains('connection'));
  });

  test('messages never include tokens or passwords', () {
    final failure = AuthFailure.fromMessage(
      'invalid refresh_token=abc.def.ghi password=secret',
    );
    expect(failure.message, isNot(contains('refresh_token')));
    expect(failure.message, isNot(contains('secret')));
    expect(failure.message, isNot(contains('abc.def')));
  });
}
