import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/app/config/config_providers.dart';
import 'package:kgwebo/app/theme/kgwebo_theme.dart';
import 'package:kgwebo/core/finance/ledger_entry.dart';
import 'package:kgwebo/core/persistence/kgwebo_database.dart';
import 'package:kgwebo/core/sync/outbox_models.dart';
import 'package:kgwebo/core/sync/outbox_store.dart';
import 'package:kgwebo/features/authentication/application/session_controller.dart';
import 'package:kgwebo/features/authentication/domain/app_session.dart';
import 'package:kgwebo/features/authentication/domain/auth_failure.dart';
import 'package:kgwebo/features/authentication/domain/auth_user.dart';
import 'package:kgwebo/features/cash_flow/presentation/cash_flow_screen.dart';
import 'package:kgwebo/features/dashboard/presentation/dashboard_screen.dart';
import 'package:kgwebo/features/onboarding/domain/business_profile.dart';
import 'package:kgwebo/features/transactions/domain/payment_method.dart';
import 'package:kgwebo/features/transactions/domain/transaction_draft.dart';

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
  const otherUser = AuthUser(
    id: 'user-2',
    email: 'other@example.com',
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
  const otherBusiness = BusinessProfile(
    id: 'biz-2',
    ownerId: 'user-2',
    name: 'Other Stall',
    businessType: 'Informal trader',
    countryCode: 'BW',
    currencyCode: 'BWP',
    openingBalanceMinor: 100000,
  );

  Future<void> pumpFinance(
    WidgetTester tester, {
    required Widget home,
    required AppSession session,
    FakeTransactionRepository? transactions,
    FakeObligationRepository? obligations,
    FakeProductRepository? products,
    KgweboDatabase? database,
  }) async {
    await setSurface(tester, const Size(360, 800));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          if (database != null)
            kgweboDatabaseProvider.overrideWith((ref) => database)
          else
            memoryDatabaseOverride(),
          appConfigProvider.overrideWithValue(
            testConfig(anonKey: 'sb_publishable_test'),
          ),
          appSessionProvider.overrideWith((ref) => session),
          currentOwnerIdProvider.overrideWithValue(
            session is AppSessionReady ? session.user.id : null,
          ),
          authRepositoryProvider.overrideWith(
            (ref) => FakeAuthRepository(
              user: session is AppSessionReady ? session.user : null,
            ),
          ),
          onboardingRepositoryProvider.overrideWith(
            (ref) => FakeOnboardingRepository(
              business: session is AppSessionReady ? session.business : null,
            ),
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
            (ref) => FakeRecommendationRepository(),
          ),
        ],
        child: MaterialApp(theme: KgweboTheme.light(), home: home),
      ),
    );
    await tester.pump();
  }

  testWidgets('cached cash is shown while the remote request is pending', (
    tester,
  ) async {
    final transactions =
        FakeTransactionRepository()
          ..items.add(sampleSale())
          ..armListAllGate();
    await pumpFinance(
      tester,
      home: const DashboardScreen(),
      session: const AppSessionReady(user: user, business: business),
      transactions: transactions,
    );

    expect(find.text('P 2,500.00'), findsWidgets);
    expect(find.text('P 500.00'), findsWidgets);
    expect(find.text('…'), findsNothing);
    expect(
      find.textContaining('Showing saved figures from this device'),
      findsOneWidget,
    );
    expect(find.textContaining('Check your connection'), findsNothing);
    expect(find.textContaining('waiting to sync'), findsNothing);

    transactions.listAllGate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('P 2,500.00'), findsWidgets);
    expect(
      find.textContaining('Showing saved figures from this device'),
      findsNothing,
    );
  });

  testWidgets('cached commitments stay visible when refresh fails', (
    tester,
  ) async {
    final obligations =
        FakeObligationRepository()
          ..items.add(
            sampleObligation(amount: 80000, dueOn: DateTime(2026, 10, 28)),
          )
          ..armListAllGate();
    await pumpFinance(
      tester,
      home: const CashFlowScreen(),
      session: const AppSessionReady(user: user, business: business),
      obligations: obligations,
    );

    expect(find.text('Shop rent'), findsWidgets);
    expect(find.text('P 1,200.00'), findsWidgets);
    expect(find.textContaining('could not be loaded'), findsNothing);
    expect(find.text('Loading bills'), findsNothing);

    obligations.listAllError = const AuthFailure.network();
    obligations.listAllGate!.complete();
    await tester.pumpAndSettle();

    expect(find.text('Shop rent'), findsWidgets);
    expect(find.text('P 1,200.00'), findsWidgets);
    expect(find.textContaining('Check your connection'), findsWidgets);
    expect(find.textContaining('could not be loaded'), findsNothing);
  });

  testWidgets('stale cache is distinct from pending synchronisation', (
    tester,
  ) async {
    final database = KgweboDatabase.memory();
    addTearDown(database.close);
    final outbox = OutboxStore(database, idGenerator: () => 'op-pending');
    await outbox.enqueue(
      ownerId: user.id,
      businessId: business.id,
      operationType: OutboxOperationTypes.createTransactionV1,
      payloadJson:
          CreateTransactionPayload.fromDraft(
            currencyCode: 'BWP',
            draft: TransactionDraft(
              type: MoneyMovementType.sale,
              amountText: '77.00',
              occurredOn: DateTime(2026, 10, 10),
              category: 'goods',
              paymentMethod: PaymentMethod.cash,
              paymentStatus: PaymentStatus.paid,
              idempotencyKey: 'pending-sale-key',
            ),
          ).encode(),
      idempotencyKey: 'pending-sale-key',
    );
    final transactions =
        FakeTransactionRepository()
          ..items.add(sampleSale())
          ..armListAllGate();

    await pumpFinance(
      tester,
      home: const DashboardScreen(),
      session: const AppSessionReady(user: user, business: business),
      transactions: transactions,
      database: database,
    );

    expect(find.text('P 2,500.00'), findsWidgets);
    expect(find.text('P 2,577.00'), findsNothing);
    expect(
      find.textContaining('Showing saved figures from this device'),
      findsOneWidget,
    );
    expect(find.textContaining('waiting to sync'), findsOneWidget);
    expect(find.textContaining('Check your connection'), findsNothing);

    transactions.listAllGate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('P 2,500.00'), findsWidgets);
    expect(find.text('P 2,577.00'), findsNothing);
    expect(find.textContaining('waiting to sync'), findsOneWidget);
    expect(
      find.textContaining('Showing saved figures from this device'),
      findsNothing,
    );
  });

  testWidgets(
    'pending entries stay excluded from confirmed cash while cache is shown',
    (tester) async {
      final transactions =
          FakeTransactionRepository()
            ..items.add(sampleSale(id: 'confirmed-sale'))
            ..items.add(
              sampleSale(id: 'pending-sale', amount: 7700, pendingSync: true),
            )
            ..armListAllGate();
      await pumpFinance(
        tester,
        home: const DashboardScreen(),
        session: const AppSessionReady(user: user, business: business),
        transactions: transactions,
      );

      expect(find.text('P 2,500.00'), findsWidgets);
      expect(find.text('P 2,577.00'), findsNothing);
      expect(find.text('P 500.00'), findsWidgets);
      expect(find.text('P 577.00'), findsNothing);

      transactions.listAllGate!.complete();
      await tester.pumpAndSettle();
      expect(find.text('P 2,500.00'), findsWidgets);
      expect(find.text('P 2,577.00'), findsNothing);
    },
  );

  testWidgets('account switch does not show another owner cache', (
    tester,
  ) async {
    final transactions =
        FakeTransactionRepository(
            ownerId: otherUser.id,
            businessId: otherBusiness.id,
          )
          ..allowAnyOwner = true
          ..items.add(sampleSale())
          ..armListAllGate();
    await pumpFinance(
      tester,
      home: const DashboardScreen(),
      session: const AppSessionReady(user: otherUser, business: otherBusiness),
      transactions: transactions,
      obligations: FakeObligationRepository(
        ownerId: otherUser.id,
        businessId: otherBusiness.id,
      )..allowAnyOwner = true,
      products: FakeProductRepository(
        ownerId: otherUser.id,
        businessId: otherBusiness.id,
      ),
    );

    expect(find.text('P 2,500.00'), findsNothing);
    expect(find.text('P 2,000.00'), findsNothing);
    expect(find.text('P 1,000.00'), findsNothing);
    expect(find.text('…'), findsWidgets);

    transactions.listAllGate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('P 1,000.00'), findsWidgets);
    expect(find.text('P 2,500.00'), findsNothing);
  });
}
