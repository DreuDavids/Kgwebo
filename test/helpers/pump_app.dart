import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kgwebo/app/app.dart';
import 'package:kgwebo/app/config/app_config.dart';
import 'package:kgwebo/app/config/app_environment.dart';
import 'package:kgwebo/app/config/config_providers.dart';
import 'package:kgwebo/core/persistence/kgwebo_database.dart';
import 'package:kgwebo/app/router.dart';
import 'package:kgwebo/app/routes.dart';
import 'package:kgwebo/app/theme/kgwebo_theme.dart';
import 'package:kgwebo/features/authentication/application/auth_repository.dart';
import 'package:kgwebo/features/authentication/application/session_controller.dart';
import 'package:kgwebo/features/authentication/domain/app_session.dart';
import 'package:kgwebo/features/onboarding/application/onboarding_repository.dart';
import 'package:kgwebo/features/obligations/application/obligation_repository.dart';
import 'package:kgwebo/features/products/application/product_repository.dart';
import 'package:kgwebo/features/recommendations/application/recommendation_repository.dart';
import 'package:kgwebo/features/transactions/application/transaction_repository.dart';

import 'fake_auth.dart';
import 'fake_obligations.dart';
import 'fake_products.dart';
import 'fake_recommendations.dart';
import 'fake_transactions.dart';
import 'test_config.dart';

Future<GoRouter> pumpKgweboApp(
  WidgetTester tester, {
  Size size = const Size(360, 800),
  double textScale = 1.0,
  AppConfig? config,
  String location = AppRoutes.dashboard,
  GoRouter? router,
  AppSession? session,
  AuthRepository? auth,
  OnboardingRepository? onboarding,
  TransactionRepository? transactions,
  ObligationRepository? obligations,
  ProductRepository? products,
  RecommendationRepository? recommendations,
  List<Override> overrides = const [],
}) async {
  await setSurface(tester, size, textScale: textScale);

  final resolvedConfig = config ?? testConfig();
  final resolvedSession = session ?? sessionForConfig(resolvedConfig);
  final appRouter =
      router ??
      createAppRouter(
        initialLocation: location,
        currentSession: () => resolvedSession,
      );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        memoryDatabaseOverride(),
        appConfigProvider.overrideWithValue(resolvedConfig),
        appSessionProvider.overrideWith((ref) => resolvedSession),
        authRepositoryProvider.overrideWith(
          (ref) => auth ?? FakeAuthRepository(),
        ),
        onboardingRepositoryProvider.overrideWith(
          (ref) => onboarding ?? FakeOnboardingRepository(),
        ),
        transactionRepositoryProvider.overrideWith(
          (ref) => transactions ?? FakeTransactionRepository(),
        ),
        obligationRepositoryProvider.overrideWith(
          (ref) => obligations ?? FakeObligationRepository(),
        ),
        productRepositoryProvider.overrideWith(
          (ref) => products ?? FakeProductRepository(),
        ),
        recommendationRepositoryProvider.overrideWith(
          (ref) => recommendations ?? FakeRecommendationRepository(),
        ),
        syncCoordinatorProvider.overrideWith((ref) => null),
        ...overrides,
      ],
      child: KgweboApp(router: appRouter),
    ),
  );
  await tester.pumpAndSettle();
  return appRouter;
}

AppSession sessionForConfig(AppConfig config) {
  return switch (config.runtimeMode) {
    AppRuntimeMode.demo ||
    AppRuntimeMode.local => AppSessionPreview(config.runtimeMode),
    AppRuntimeMode.live => const AppSessionGuest(),
  };
}

Override memoryDatabaseOverride() {
  return kgweboDatabaseProvider.overrideWith((ref) {
    final database = KgweboDatabase.memory();
    ref.onDispose(database.close);
    return database;
  });
}

Future<void> setSurface(
  WidgetTester tester,
  Size size, {
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Future<void> selectDashboardTab(WidgetTester tester, String label) async {
  final key = ValueKey('dashboard-tab-${label.toLowerCase()}');
  final keyed = find.byKey(key);
  final target = keyed.evaluate().isEmpty ? find.text(label) : keyed;
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> pumpThemed(
  WidgetTester tester, {
  required Widget child,
  Size size = const Size(360, 800),
}) async {
  await setSurface(tester, size);

  await tester.pumpWidget(MaterialApp(theme: KgweboTheme.light(), home: child));
}
