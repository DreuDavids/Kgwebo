import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/route_access.dart';
import '../features/authentication/application/session_controller.dart';
import '../features/authentication/domain/app_session.dart';
import '../features/authentication/presentation/confirm_email_screen.dart';
import '../features/authentication/presentation/forgot_password_screen.dart';
import '../features/authentication/presentation/reset_password_screen.dart';
import '../features/authentication/presentation/session_loading_screen.dart';
import '../features/authentication/presentation/sign_in_screen.dart';
import '../features/authentication/presentation/sign_up_screen.dart';
import '../features/authentication/presentation/welcome_screen.dart';
import '../features/cash_flow/presentation/cash_flow_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/more/presentation/more_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/products/presentation/products_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/business/presentation/business_profile_edit_screen.dart';
import '../features/business/presentation/business_profile_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/shell/app_shell.dart';
import '../features/transactions/presentation/transactions_screen.dart';
import 'config/app_environment.dart';
import 'routes.dart';
import 'widgets/unknown_route_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen<AppSession>(appSessionProvider, (_, __) {
    refresh.value++;
  });
  ref.onDispose(refresh.dispose);
  return createAppRouter(
    currentSession: () => ref.read(appSessionProvider),
    refreshListenable: refresh,
  );
});

GoRouter createAppRouter({
  String initialLocation = AppRoutes.dashboard,
  List<NavigatorObserver>? observers,
  Listenable? refreshListenable,
  AppSession Function()? currentSession,
}) {
  AppSession session() =>
      currentSession?.call() ?? const AppSessionPreview(AppRuntimeMode.local);

  return GoRouter(
    initialLocation: initialLocation,
    observers: observers ?? const [],
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      return redirectFor(session(), state.uri.toString());
    },
    errorBuilder: (context, state) {
      return UnknownRouteScreen(location: state.uri.toString());
    },
    routes: [
      GoRoute(
        path: AppRoutes.root,
        redirect: (context, state) => AppRoutes.dashboard,
      ),
      GoRoute(
        path: AppRoutes.session,
        name: AppRoutes.sessionName,
        builder: (context, state) => const SessionLoadingScreen(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        name: AppRoutes.welcomeName,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        name: AppRoutes.signInName,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        name: AppRoutes.signUpName,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: AppRoutes.forgotPasswordName,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        name: AppRoutes.resetPasswordName,
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.confirmEmail,
        name: AppRoutes.confirmEmailName,
        builder: (context, state) => const ConfirmEmailScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRoutes.onboardingName,
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                name: AppRoutes.dashboardName,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.transactions,
                name: AppRoutes.transactionsName,
                builder: (context, state) => const TransactionsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.products,
                name: AppRoutes.productsName,
                builder: (context, state) => const ProductsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.cashFlow,
                name: AppRoutes.cashFlowName,
                builder: (context, state) => const CashFlowScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.reports,
                name: AppRoutes.reportsName,
                builder: (context, state) => const ReportsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                name: AppRoutes.settingsName,
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'business',
                    name: AppRoutes.businessProfileName,
                    builder: (context, state) => const BusinessProfileScreen(),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        name: AppRoutes.businessProfileEditName,
                        builder:
                            (context, state) =>
                                const BusinessProfileEditScreen(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.more,
                name: AppRoutes.moreName,
                builder: (context, state) => const MoreScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
