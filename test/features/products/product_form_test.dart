import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/app/config/config_providers.dart';
import 'package:kgwebo/app/theme/kgwebo_theme.dart';
import 'package:kgwebo/features/authentication/application/session_controller.dart';
import 'package:kgwebo/features/authentication/domain/app_session.dart';
import 'package:kgwebo/features/authentication/domain/auth_user.dart';
import 'package:kgwebo/features/onboarding/domain/business_profile.dart';
import 'package:kgwebo/features/products/domain/stock_movement_type.dart';
import 'package:kgwebo/features/products/presentation/product_form_screen.dart';
import 'package:kgwebo/features/products/presentation/products_screen.dart';
import 'package:kgwebo/features/products/presentation/stock_movement_form_screen.dart';

import '../../helpers/fake_auth.dart';
import '../../helpers/fake_obligations.dart';
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

  Future<FakeProductRepository> pumpForm(
    WidgetTester tester, {
    FakeProductRepository? repository,
    Size size = const Size(360, 800),
  }) async {
    final products = repository ?? FakeProductRepository();
    await setSurface(tester, size);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            testConfig(anonKey: 'sb_publishable_test'),
          ),
          appSessionProvider.overrideWith(
            (ref) => AppSessionReady(user: user, business: business),
          ),
          currentOwnerIdProvider.overrideWithValue(user.id),
          authRepositoryProvider.overrideWith(
            (ref) => FakeAuthRepository(user: user),
          ),
          onboardingRepositoryProvider.overrideWith(
            (ref) => FakeOnboardingRepository(business: business),
          ),
          transactionRepositoryProvider.overrideWith(
            (ref) => FakeTransactionRepository(),
          ),
          obligationRepositoryProvider.overrideWith(
            (ref) => FakeObligationRepository(),
          ),
          productRepositoryProvider.overrideWith((ref) => products),
        ],
        child: MaterialApp(
          theme: KgweboTheme.light(),
          home: const ProductFormScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return products;
  }

  testWidgets('form validates empty name and price', (tester) async {
    await pumpForm(tester);
    await tester.ensureVisible(find.text('Save stock'));
    await tester.tap(find.text('Save stock'));
    await tester.pumpAndSettle();
    expect(
      find.text('Enter a product name, up to 120 characters.'),
      findsOneWidget,
    );
    expect(
      find.text('Enter a positive selling price, for example 12.50.'),
      findsOneWidget,
    );
  });

  testWidgets('duplicate taps create one product', (tester) async {
    final products = await pumpForm(tester);
    await tester.enterText(find.byType(TextField).at(0), 'Soap');
    await tester.enterText(find.byType(TextField).at(3), '8.00');
    await tester.ensureVisible(find.text('Save stock'));
    await tester.tap(find.text('Save stock'));
    await tester.pumpAndSettle();
    expect(products.createCalls, 1);
    expect(products.products.single.name, 'Soap');
  });

  testWidgets('product list remains usable at 320x568', (tester) async {
    final products = FakeProductRepository(products: [sampleProduct()]);
    await setSurface(tester, const Size(320, 568));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            testConfig(anonKey: 'sb_publishable_test'),
          ),
          appSessionProvider.overrideWith(
            (ref) => AppSessionReady(user: user, business: business),
          ),
          currentOwnerIdProvider.overrideWithValue(user.id),
          authRepositoryProvider.overrideWith(
            (ref) => FakeAuthRepository(user: user),
          ),
          onboardingRepositoryProvider.overrideWith(
            (ref) => FakeOnboardingRepository(business: business),
          ),
          transactionRepositoryProvider.overrideWith(
            (ref) => FakeTransactionRepository(),
          ),
          obligationRepositoryProvider.overrideWith(
            (ref) => FakeObligationRepository(),
          ),
          productRepositoryProvider.overrideWith((ref) => products),
        ],
        child: MaterialApp(
          theme: KgweboTheme.light(),
          home: const ProductsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(products.listCalls, greaterThan(0));
    expect(find.text('Loading products'), findsNothing);
    expect(find.text('Estimated inventory value'), findsOneWidget);
    final listScrollable = find.descendant(
      of: find.byType(RefreshIndicator),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.text('Tomatoes'),
      64,
      scrollable: listScrollable,
    );
    expect(find.text('Tomatoes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('stock form requires a quantity and confirms write-offs', (
    tester,
  ) async {
    final products = FakeProductRepository(products: [sampleProduct()]);
    await setSurface(tester, const Size(360, 800));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            testConfig(anonKey: 'sb_publishable_test'),
          ),
          appSessionProvider.overrideWith(
            (ref) => AppSessionReady(user: user, business: business),
          ),
          currentOwnerIdProvider.overrideWithValue(user.id),
          authRepositoryProvider.overrideWith(
            (ref) => FakeAuthRepository(user: user),
          ),
          onboardingRepositoryProvider.overrideWith(
            (ref) => FakeOnboardingRepository(business: business),
          ),
          transactionRepositoryProvider.overrideWith(
            (ref) => FakeTransactionRepository(),
          ),
          obligationRepositoryProvider.overrideWith(
            (ref) => FakeObligationRepository(),
          ),
          productRepositoryProvider.overrideWith((ref) => products),
        ],
        child: MaterialApp(
          theme: KgweboTheme.light(),
          home: const StockMovementFormScreen(
            productId: 'prod-1',
            type: StockMovementType.damaged,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save movement'));
    await tester.tap(find.text('Save movement'));
    await tester.pumpAndSettle();
    expect(
      find.text('Enter how many units this movement covers.'),
      findsOneWidget,
    );
    expect(
      find.text('Enter a reason for this correction or write-off.'),
      findsOneWidget,
    );
    expect(products.movementCalls, 0);

    await tester.enterText(find.byType(TextField).first, '1');
    await tester.enterText(find.byType(TextField).at(1), 'Broken crate');
    await tester.ensureVisible(find.text('Save movement'));
    await tester.tap(find.text('Save movement'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm this stock change?'), findsOneWidget);
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(products.movementCalls, 1);
    expect(products.products.single.stockQuantityMilli, 4000);
  });
}
