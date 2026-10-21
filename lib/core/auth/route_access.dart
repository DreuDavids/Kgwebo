import '../../app/routes.dart';
import '../../features/authentication/domain/app_session.dart';

const _protected = {
  AppRoutes.dashboard,
  AppRoutes.transactions,
  AppRoutes.products,
  AppRoutes.cashFlow,
  AppRoutes.reports,
  AppRoutes.settings,
  AppRoutes.businessProfile,
  AppRoutes.businessProfileEdit,
  AppRoutes.more,
};

const _authRoutes = {
  AppRoutes.welcome,
  AppRoutes.signIn,
  AppRoutes.signUp,
  AppRoutes.forgotPassword,
  AppRoutes.resetPassword,
  AppRoutes.confirmEmail,
};

/// Pure navigation policy. UI hiding is not a substitute for this, and this
/// is not a substitute for Row Level Security.
String? redirectFor(AppSession session, String location) {
  final path = location.split('?').first;
  if (!_isKnownAppPath(path)) {
    return null;
  }

  return switch (session) {
    AppSessionLoading() || AppSessionResolving() =>
      path == AppRoutes.session ? null : AppRoutes.session,
    AppSessionPreview() =>
      _authRoutes.contains(path) ||
              path == AppRoutes.onboarding ||
              path == AppRoutes.session ||
              path == AppRoutes.root
          ? AppRoutes.dashboard
          : null,
    AppSessionGuest() => _guestRedirect(path),
    AppSessionNeedsEmailConfirmation() =>
      path == AppRoutes.confirmEmail ? null : AppRoutes.confirmEmail,
    AppSessionPasswordRecovery() =>
      path == AppRoutes.resetPassword ? null : AppRoutes.resetPassword,
    AppSessionNeedsOnboarding() || AppSessionFailure() =>
      path == AppRoutes.onboarding ? null : AppRoutes.onboarding,
    AppSessionReady() =>
      _authRoutes.contains(path) ||
              path == AppRoutes.onboarding ||
              path == AppRoutes.session ||
              path == AppRoutes.root
          ? AppRoutes.dashboard
          : null,
  };
}

String? _guestRedirect(String path) {
  if (_protected.contains(path) ||
      path == AppRoutes.onboarding ||
      path == AppRoutes.session ||
      path == AppRoutes.root) {
    return AppRoutes.welcome;
  }
  return null;
}

bool _isKnownAppPath(String path) {
  return path == AppRoutes.root ||
      path == AppRoutes.session ||
      path == AppRoutes.onboarding ||
      _protected.contains(path) ||
      _authRoutes.contains(path);
}
