import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/app/config/config_providers.dart';
import 'package:kgwebo/app/theme/kgwebo_theme.dart';
import 'package:kgwebo/features/authentication/application/session_controller.dart';
import 'package:kgwebo/features/authentication/domain/app_session.dart';
import 'package:kgwebo/features/authentication/domain/auth_failure.dart';
import 'package:kgwebo/features/authentication/domain/auth_user.dart';
import 'package:kgwebo/core/finance/business_calendar.dart';
import 'package:kgwebo/core/finance/cash_outlook.dart';
import 'package:kgwebo/features/dashboard/presentation/dashboard_screen.dart';
import 'package:kgwebo/features/onboarding/domain/business_profile.dart';

import '../../helpers/fake_auth.dart';
import '../../helpers/fake_obligations.dart';
import '../../helpers/fake_products.dart';
import '../../helpers/fake_recommendations.dart';
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

  Future<void> pumpDashboard(
    WidgetTester tester, {
    required FakeTransactionRepository repository,
    FakeObligationRepository? obligations,
    FakeProductRepository? products,
    bool stale = false,
  }) async {
    await setSurface(tester, const Size(360, 800));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          memoryDatabaseOverride(),
          appConfigProvider.overrideWithValue(
            testConfig(anonKey: 'sb_publishable_test'),
          ),
          appSessionProvider.overrideWith(
            (ref) =>
                AppSessionReady(user: user, business: business, isStale: stale),
          ),
          currentOwnerIdProvider.overrideWithValue(user.id),
          authRepositoryProvider.overrideWith(
            (ref) => FakeAuthRepository(user: user),
          ),
          onboardingRepositoryProvider.overrideWith(
            (ref) => FakeOnboardingRepository(business: business),
          ),
          transactionRepositoryProvider.overrideWith((ref) => repository),
          obligationRepositoryProvider.overrideWith(
            (ref) => obligations ?? FakeObligationRepository(),
          ),
          productRepositoryProvider.overrideWith(
            (ref) => products ?? FakeProductRepository(),
          ),
          recommendationRepositoryProvider.overrideWith(
            (ref) => FakeRecommendationRepository(),
          ),
        ],
        child: MaterialApp(
          theme: KgweboTheme.light(),
          home: const DashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('preview dashboard does not show live totals', (tester) async {
    await pumpKgweboApp(tester);
    expect(find.textContaining('labelled preview'), findsOneWidget);
    expect(find.text('Overview'), findsOneWidget);
    await selectDashboardTab(tester, 'Records');
    expect(find.text('Record a sale'), findsOneWidget);
  });

  testWidgets('empty live dashboard uses opening cash not a fake profit', (
    tester,
  ) async {
    await pumpDashboard(tester, repository: FakeTransactionRepository());
    expect(find.text('P 2,000.00'), findsWidgets);
    expect(find.textContaining('opening / starting cash'), findsOneWidget);
    expect(find.text('P 0.00'), findsWidgets);
  });

  testWidgets('populated dashboard matches recorded sales', (tester) async {
    final repository = FakeTransactionRepository()..items.add(sampleSale());
    await pumpDashboard(tester, repository: repository);
    expect(find.text('P 500.00'), findsWidgets);
    expect(find.text('P 2,500.00'), findsWidgets);
  });

  testWidgets('stale dashboard is labelled', (tester) async {
    final repository = FakeTransactionRepository()..items.add(sampleSale());
    await pumpDashboard(tester, repository: repository, stale: true);
    expect(
      find.textContaining('Showing saved figures from this device'),
      findsOneWidget,
    );
  });

  testWidgets('failed load is not shown as zero', (tester) async {
    final repository =
        FakeTransactionRepository()..nextError = const AuthFailure.network();
    await pumpDashboard(tester, repository: repository);
    expect(find.textContaining('not a zero result'), findsOneWidget);
    expect(find.text('P 0.00'), findsNothing);
  });

  testWidgets('period selector recalculates sales without changing cash', (
    tester,
  ) async {
    final repository =
        FakeTransactionRepository()
          ..items.add(
            sampleSale(
              id: 'oct-sale',
              amount: 50000,
              occurredAt: BusinessCalendar.utcFromGaborone(
                year: 2026,
                month: 10,
                day: 10,
              ),
            ),
          )
          ..items.add(
            sampleSale(
              id: 'sep-sale',
              amount: 30000,
              occurredAt: BusinessCalendar.utcFromGaborone(
                year: 2026,
                month: 9,
                day: 10,
              ),
            ),
          );
    await pumpDashboard(tester, repository: repository);
    expect(find.text('This month'), findsOneWidget);
    expect(find.text('P 500.00'), findsWidgets);
    expect(find.text('P 2,800.00'), findsWidgets);

    await tester.tap(find.text('Last month'));
    await tester.pumpAndSettle();
    expect(find.text('P 300.00'), findsWidgets);
    expect(find.text('P 2,800.00'), findsWidgets);
  });

  testWidgets('unpaid commitment does not reduce recorded cash', (
    tester,
  ) async {
    final obligations =
        FakeObligationRepository()
          ..items.add(
            sampleObligation(amount: 80000, dueOn: DateTime(2026, 10, 28)),
          );
    await pumpDashboard(
      tester,
      repository: FakeTransactionRepository(),
      obligations: obligations,
    );
    expect(find.text('P 2,000.00'), findsWidgets);
    expect(find.text('P 0.00'), findsWidgets);
    await selectDashboardTab(tester, 'Outlook');
    await tester.ensureVisible(
      find.textContaining('Estimated cash after known commitments'),
    );
    expect(find.text('P 1,200.00'), findsWidgets);
    expect(find.text('Shop rent'), findsOneWidget);
    expect(
      find.textContaining('Recorded cash P 2,000.00 is unchanged'),
      findsOneWidget,
    );
  });

  testWidgets('marking a commitment paid does not create an expense', (
    tester,
  ) async {
    final obligations =
        FakeObligationRepository()
          ..items.add(
            sampleObligation(
              amount: 80000,
              dueOn: DateTime(2026, 10, 28),
              status: CommitmentStatus.paid,
            ),
          );
    await pumpDashboard(
      tester,
      repository: FakeTransactionRepository(),
      obligations: obligations,
    );
    expect(find.text('P 2,000.00'), findsWidgets);
    expect(find.text('P 0.00'), findsWidgets);
    await selectDashboardTab(tester, 'Outlook');
    await tester.ensureVisible(
      find.textContaining('Estimated cash after known commitments'),
    );
    expect(find.text('P 1,200.00'), findsNothing);
    expect(find.text('Shop rent'), findsNothing);
  });

  testWidgets(
    'recording the matching expense does not double-count a paid commitment',
    (tester) async {
      final repository =
          FakeTransactionRepository()..items.add(sampleExpense(amount: 80000));
      final obligations =
          FakeObligationRepository()
            ..items.add(
              sampleObligation(
                amount: 80000,
                dueOn: DateTime(2026, 10, 28),
                status: CommitmentStatus.paid,
              ),
            );
      await pumpDashboard(
        tester,
        repository: repository,
        obligations: obligations,
      );
      expect(find.text('P 1,200.00'), findsWidgets);
      expect(find.text('P 800.00'), findsWidgets);
      expect(find.text('P 1,600.00'), findsNothing);
    },
  );

  testWidgets('failed commitment refresh is not shown as zero unpaid bills', (
    tester,
  ) async {
    final obligations =
        FakeObligationRepository()..nextError = const AuthFailure.network();
    await pumpDashboard(
      tester,
      repository: FakeTransactionRepository()..items.add(sampleSale()),
      obligations: obligations,
    );
    expect(find.text('P 2,500.00'), findsWidgets);
    expect(find.textContaining('Check your connection'), findsOneWidget);
    expect(
      find.textContaining('Estimated cash after known commitments'),
      findsNothing,
    );
    await selectDashboardTab(tester, 'Outlook');
    expect(
      find.textContaining('Estimated cash after known commitments'),
      findsNothing,
    );
    expect(find.textContaining('not a zero-bills result'), findsOneWidget);
  });

  testWidgets('low stock is a restock notice and not treated as cash', (
    tester,
  ) async {
    await pumpDashboard(
      tester,
      repository: FakeTransactionRepository(),
      products: FakeProductRepository(
        products: [sampleProduct(stockQuantityMilli: 0)],
      ),
    );
    expect(find.textContaining('need restocking'), findsOneWidget);
    expect(find.textContaining('Inventory value is not cash'), findsOneWidget);
  });

  testWidgets('home tabs split overview, records and outlook', (tester) async {
    final obligations =
        FakeObligationRepository()
          ..items.add(
            sampleObligation(amount: 80000, dueOn: DateTime(2026, 10, 28)),
          );
    await pumpDashboard(
      tester,
      repository: FakeTransactionRepository()..items.add(sampleSale()),
      obligations: obligations,
    );

    expect(find.text('Your cash'), findsOneWidget);
    expect(find.text('Record a sale'), findsNothing);
    expect(
      find.textContaining('Estimated cash after known commitments'),
      findsNothing,
    );

    await selectDashboardTab(tester, 'Records');
    expect(find.text('Record a sale'), findsOneWidget);
    expect(find.text('Your cash'), findsNothing);

    await selectDashboardTab(tester, 'Outlook');
    expect(
      find.textContaining('Estimated cash after known commitments'),
      findsOneWidget,
    );
    expect(find.text('Record a sale'), findsNothing);
  });
}
