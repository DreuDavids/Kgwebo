/// Local credential checks. Passing these does not guarantee the server
/// will accept the same values.
String? validateEmail(String value) {
  final email = value.trim();
  if (email.isEmpty) {
    return 'Enter your email address.';
  }
  final at = email.indexOf('@');
  final dot = email.lastIndexOf('.');
  if (at < 1 || dot < at + 2 || dot == email.length - 1) {
    return 'Enter a valid email address.';
  }
  return null;
}

String? validatePassword(String value) {
  if (value.isEmpty) {
    return 'Enter a password.';
  }
  if (value.length < 8) {
    return 'Use at least 8 characters.';
  }
  if (value.length > 72) {
    return 'Use 72 characters or fewer.';
  }
  return null;
}

String? validatePasswordConfirmation({
  required String password,
  required String confirmation,
}) {
  if (confirmation != password) {
    return 'Passwords do not match.';
  }
  return null;
}

const authOtpLength = 6;
final _otpPattern = RegExp(r'^\d{6}$');

String? validateOtp(String value) {
  final code = value.trim();
  if (!_otpPattern.hasMatch(code)) {
    return 'Enter the 6-character code.';
  }
  return null;
}
