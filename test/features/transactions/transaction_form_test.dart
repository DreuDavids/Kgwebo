import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/app/config/config_providers.dart';
import 'package:kgwebo/app/theme/kgwebo_theme.dart';
import 'package:kgwebo/core/finance/ledger_entry.dart';
import 'package:kgwebo/features/authentication/application/session_controller.dart';
import 'package:kgwebo/features/authentication/domain/app_session.dart';
import 'package:kgwebo/features/authentication/domain/auth_failure.dart';
import 'package:kgwebo/features/authentication/domain/auth_user.dart';
import 'package:kgwebo/features/onboarding/domain/business_profile.dart';
import 'package:kgwebo/features/transactions/presentation/transaction_form_screen.dart';

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

  Future<FakeTransactionRepository> pumpForm(
    WidgetTester tester, {
    MoneyMovementType type = MoneyMovementType.sale,
    FakeTransactionRepository? repository,
    FakeProductRepository? products,
    Size size = const Size(360, 800),
    AppSession? session,
  }) async {
    final transactions = repository ?? FakeTransactionRepository();
    final catalog = products ?? FakeProductRepository();
    await setSurface(tester, size);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          memoryDatabaseOverride(),
          appConfigProvider.overrideWithValue(
            testConfig(anonKey: 'sb_publishable_test'),
          ),
          appSessionProvider.overrideWith(
            (ref) => session ?? AppSessionReady(user: user, business: business),
          ),
          currentOwnerIdProvider.overrideWithValue(user.id),
          authRepositoryProvider.overrideWith(
            (ref) => FakeAuthRepository(user: user),
          ),
          onboardingRepositoryProvider.overrideWith(
            (ref) => FakeOnboardingRepository(business: business),
          ),
          transactionRepositoryProvider.overrideWith((ref) => transactions),
          productRepositoryProvider.overrideWith((ref) => catalog),
        ],
        child: MaterialApp(
          theme: KgweboTheme.light(),
          home: TransactionFormScreen(type: type),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return transactions;
  }

  testWidgets('sale form validates empty amount', (tester) async {
    await pumpForm(tester);
    expect(find.text('Record a sale'), findsOneWidget);
    await tester.ensureVisible(find.text('Save sale'));
    await tester.tap(find.text('Save sale'));
    await tester.pumpAndSettle();
    expect(
      find.text('Enter a positive amount, for example 50.00.'),
      findsOneWidget,
    );
  });

  testWidgets('sale form saves a valid amount once', (tester) async {
    final repository = await pumpForm(tester);
    await tester.enterText(find.byType(TextField).first, '50.00');
    await tester.ensureVisible(find.text('Save sale'));
    await tester.tap(find.text('Save sale'));
    await tester.pumpAndSettle();
    expect(repository.createCalls, 1);
    expect(repository.items.single.amountMinor, 5000);
    expect(repository.items.single.type, MoneyMovementType.sale);
  });

  testWidgets('duplicate taps while saving do not create two sales', (
    tester,
  ) async {
    final repository =
        FakeTransactionRepository()
          ..createDelay = const Duration(milliseconds: 400);
    await pumpForm(tester, repository: repository);
    await tester.enterText(find.byType(TextField).first, '50.00');
    await tester.ensureVisible(find.text('Save sale'));
    await tester.tap(find.text('Save sale'));
    await tester.tap(find.text('Save sale'));
    await tester.pumpAndSettle();
    expect(repository.createCalls, 1);
    expect(repository.items, hasLength(1));
  });

  testWidgets('failed save keeps the entered amount', (tester) async {
    final repository =
        FakeTransactionRepository()..nextError = const AuthFailure.network();
    await pumpForm(tester, repository: repository);
    await tester.enterText(find.byType(TextField).first, '75.50');
    await tester.ensureVisible(find.text('Save sale'));
    await tester.tap(find.text('Save sale'));
    await tester.pumpAndSettle();
    expect(find.text('75.50'), findsOneWidget);
    expect(find.text('Check your connection and try again.'), findsOneWidget);
    expect(repository.items, isEmpty);
  });

  testWidgets('expense form is labelled as an expense', (tester) async {
    await pumpForm(tester, type: MoneyMovementType.expense);
    expect(find.text('Record an expense'), findsOneWidget);
    expect(find.textContaining('this expense can wait'), findsOneWidget);
  });

  testWidgets('product picker uses the business currency, not hardcoded BWP', (
    tester,
  ) async {
    const zarBusiness = BusinessProfile(
      id: 'biz-1',
      ownerId: 'user-1',
      name: 'Kgale Stall',
      businessType: 'Informal trader',
      countryCode: 'ZA',
      currencyCode: 'ZAR',
      openingBalanceMinor: 200000,
    );
    final products = FakeProductRepository(products: [sampleProduct()]);
    await pumpForm(
      tester,
      products: products,
      session: AppSessionReady(user: user, business: zarBusiness),
    );
    await tester.ensureVisible(find.text('What did you sell?'));
    await tester.tap(find.text('What did you sell?'));
    await tester.pumpAndSettle();
    expect(find.textContaining('ZAR 12.50'), findsOneWidget);
    expect(find.textContaining('P 12.50'), findsNothing);
  });

  testWidgets('adding a product records one inventory sale', (tester) async {
    final products = FakeProductRepository(products: [sampleProduct()]);
    final transactions = await pumpForm(tester, products: products);
    await tester.ensureVisible(find.text('What did you sell?'));
    await tester.tap(find.text('What did you sell?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tomatoes'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save sale'));
    await tester.tap(find.text('Save sale'));
    await tester.pumpAndSettle();
    expect(products.saleCalls, 1);
    expect(products.sales, hasLength(1));
    expect(products.sales.single.amountMinor, 1250);
    expect(transactions.createCalls, 0);
    expect(products.products.single.stockQuantityMilli, 4000);
  });

  testWidgets('sale form stays usable at 320x568 with keyboard inset', (
    tester,
  ) async {
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(() => tester.view.resetViewInsets());
    final overflows = <String>[];
    final original = FlutterError.onError;
    FlutterError.onError = (details) {
      final text = details.exceptionAsString();
      if (text.contains('overflowed')) {
        overflows.add(text);
      }
      original?.call(details);
    };
    addTearDown(() => FlutterError.onError = original);

    await pumpForm(tester, size: const Size(320, 568));
    expect(find.text('Record a sale'), findsOneWidget);
    expect(find.text('Save sale'), findsOneWidget);
    expect(overflows, isEmpty);
  });
}
