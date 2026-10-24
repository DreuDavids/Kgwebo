import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kgwebo/app/config/config_providers.dart';
import 'package:kgwebo/app/routes.dart';
import 'package:kgwebo/app/theme/kgwebo_theme.dart';
import 'package:kgwebo/features/authentication/application/session_controller.dart';
import 'package:kgwebo/features/authentication/domain/app_session.dart';
import 'package:kgwebo/features/authentication/domain/auth_user.dart';
import 'package:kgwebo/features/onboarding/domain/business_profile.dart';
import 'package:kgwebo/features/transactions/presentation/transaction_details_screen.dart';
import 'package:kgwebo/features/transactions/presentation/transactions_screen.dart';

import '../../helpers/fake_auth.dart';
import '../../helpers/fake_products.dart';
import '../../helpers/fake_transactions.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_config.dart';

void main() {
  const user = AuthUser(
    id: 'user-1',
    email: 'owner@example.com',
    emailConfirmed: true,
  );
  const business = BusinessProfile(
    id: 'biz-1',
    ownerId: 'user-1',
    name: 'Kgale Stall',
    businessType: 'Informal trader',
    countryCode: 'BW',
    currencyCode: 'BWP',
    openingBalanceMinor: 200000,
  );

  Future<void> pumpHistory(
    WidgetTester tester, {
    required FakeTransactionRepository repository,
    Size size = const Size(360, 800),
  }) async {
    final session = AppSessionReady(user: user, business: business);
    await setSurface(tester, size);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          memoryDatabaseOverride(),
          appConfigProvider.overrideWithValue(
            testConfig(anonKey: 'sb_publishable_test'),
          ),
          appSessionProvider.overrideWith((ref) => session),
          currentOwnerIdProvider.overrideWithValue(user.id),
          authRepositoryProvider.overrideWith(
            (ref) => FakeAuthRepository(user: user),
          ),
          onboardingRepositoryProvider.overrideWith(
            (ref) => FakeOnboardingRepository(business: business),
          ),
          transactionRepositoryProvider.overrideWith((ref) => repository),
          productRepositoryProvider.overrideWith(
            (ref) => FakeProductRepository(),
          ),
        ],
        child: MaterialApp(
          theme: KgweboTheme.light(),
          home: const TransactionsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty history explains that opening cash is not listed', (
    tester,
  ) async {
    await pumpHistory(tester, repository: FakeTransactionRepository());
    expect(find.text('No money recorded yet'), findsOneWidget);
    expect(
      find.textContaining('Opening cash is a starting balance'),
      findsOneWidget,
    );
  });

  testWidgets('populated history shows formatted sale amounts', (tester) async {
    final repository = FakeTransactionRepository()..items.add(sampleSale());
    await pumpHistory(tester, repository: repository);
    expect(find.textContaining('P 500.00'), findsOneWidget);
    expect(find.textContaining('Goods sold'), findsOneWidget);
  });

  testWidgets('search filters visible rows', (tester) async {
    final repository = FakeTransactionRepository()..items.add(sampleSale());
    await pumpHistory(tester, repository: repository);
    await tester.enterText(find.byType(TextField).first, 'not-a-match');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('No money recorded yet'), findsOneWidget);
  });

  testWidgets('delete confirmation is required', (tester) async {
    final repository = FakeTransactionRepository()..items.add(sampleSale());
    final session = AppSessionReady(user: user, business: business);
    await setSurface(tester, const Size(360, 800));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          memoryDatabaseOverride(),
          appConfigProvider.overrideWithValue(
            testConfig(anonKey: 'sb_publishable_test'),
          ),
          appSessionProvider.overrideWith((ref) => session),
          currentOwnerIdProvider.overrideWithValue(user.id),
          transactionRepositoryProvider.overrideWith((ref) => repository),
          productRepositoryProvider.overrideWith(
            (ref) => FakeProductRepository(),
          ),
        ],
        child: MaterialApp.router(
          theme: KgweboTheme.light(),
          routerConfig: GoRouter(
            initialLocation: '/transactions/${sampleSale().id}',
            routes: [
              GoRoute(
                path: '/transactions/:transactionId',
                builder:
                    (context, state) => TransactionDetailsScreen(
                      transactionId: state.pathParameters['transactionId']!,
                    ),
              ),
              GoRoute(
                path: AppRoutes.transactions,
                builder: (context, state) => const TransactionsScreen(),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this transaction?'), findsOneWidget);
    expect(repository.deleteCalls, 0);
    await tester.tap(find.text('Keep it'));
    await tester.pumpAndSettle();
    expect(repository.items, hasLength(1));
  });
}
