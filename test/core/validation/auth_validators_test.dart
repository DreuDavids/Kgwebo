import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/validation/auth_validators.dart';

void main() {
  group('validateEmail', () {
    test('rejects empty and whitespace', () {
      expect(validateEmail(''), 'Enter your email address.');
      expect(validateEmail('   '), 'Enter your email address.');
    });

    test('rejects values that are not an email shape', () {
      expect(validateEmail('not-an-email'), isNotNull);
      expect(validateEmail('missing@domain'), isNotNull);
      expect(validateEmail('name@'), isNotNull);
    });

    test(
      'accepts a trimmed typical address without claiming server acceptance',
      () {
        expect(validateEmail('  owner@example.com  '), isNull);
      },
    );
  });

  group('validatePassword', () {
    test('rejects empty passwords', () {
      expect(validatePassword(''), 'Enter a password.');
    });

    test('rejects passwords shorter than 8 characters', () {
      expect(validatePassword('short'), contains('8'));
    });

    test('rejects passwords longer than 72 characters', () {
      expect(validatePassword('a' * 73), contains('72'));
    });

    test('accepts an 8-character password for local checks only', () {
      expect(validatePassword('correct1'), isNull);
    });
  });

  group('validatePasswordConfirmation', () {
    test('requires a matching confirmation', () {
      expect(
        validatePasswordConfirmation(
          password: 'correct1',
          confirmation: 'other123',
        ),
        'Passwords do not match.',
      );
    });

    test('accepts matching confirmation', () {
      expect(
        validatePasswordConfirmation(
          password: 'correct1',
          confirmation: 'correct1',
        ),
        isNull,
      );
    });
  });
}
