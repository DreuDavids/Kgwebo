import 'auth_user.dart';

sealed class SignUpResult {
  const SignUpResult();
}

final class SignUpSessionCreated extends SignUpResult {
  const SignUpSessionCreated(this.user);

  final AuthUser user;
}

final class SignUpConfirmationRequired extends SignUpResult {
  const SignUpConfirmationRequired(this.email);

  final String email;
}
