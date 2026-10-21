import '../../../app/config/app_environment.dart';
import '../../onboarding/domain/business_profile.dart';
import 'auth_user.dart';

sealed class AppSession {
  const AppSession();
}

final class AppSessionLoading extends AppSession {
  const AppSessionLoading();
}

final class AppSessionResolving extends AppSession {
  const AppSessionResolving();
}

final class AppSessionPreview extends AppSession {
  const AppSessionPreview(this.mode);

  final AppRuntimeMode mode;
}

final class AppSessionGuest extends AppSession {
  const AppSessionGuest();
}

final class AppSessionNeedsEmailConfirmation extends AppSession {
  const AppSessionNeedsEmailConfirmation({required this.email, this.user});

  final String email;
  final AuthUser? user;
}

final class AppSessionPasswordRecovery extends AppSession {
  const AppSessionPasswordRecovery(this.user);

  final AuthUser user;
}

final class AppSessionNeedsOnboarding extends AppSession {
  const AppSessionNeedsOnboarding(this.user);

  final AuthUser user;
}

final class AppSessionReady extends AppSession {
  const AppSessionReady({
    required this.user,
    required this.business,
    this.isStale = false,
  });

  final AuthUser user;
  final BusinessProfile business;
  final bool isStale;
}

final class AppSessionFailure extends AppSession {
  const AppSessionFailure(this.message, {this.user});

  final String message;
  final AuthUser? user;
}
