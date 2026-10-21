import 'auth_user.dart';

enum AuthChangeKind {
  initial,
  signedIn,
  signedOut,
  passwordRecovery,
  tokenRefreshed,
  userUpdated,
  userDeleted,
}

class AuthChange {
  const AuthChange({required this.kind, this.user});

  final AuthChangeKind kind;
  final AuthUser? user;
}
