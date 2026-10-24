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
import 'package:kgwebo/features/onboarding/domain/business_profile.dart';
import 'package:kgwebo/features/sync/presentation/sync_queue_screen.dart';
import 'package:kgwebo/features/sync/presentation/sync_status_label.dart';
import 'package:kgwebo/features/transactions/domain/payment_method.dart';
import 'package:kgwebo/features/transactions/domain/transaction_draft.dart';

import '../../helpers/fake_auth.dart';
import '../../helpers/fake_obligations.dart';
import '../../helpers/fake_products.dart';
import '../../helpers/fake_transactions.dart';
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

  testWidgets('empty queue explains that confirmed records are on the server', (
    tester,
  ) async {
    final database = KgweboDatabase.memory();
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          kgweboDatabaseProvider.overrideWith((ref) => database),
          syncCoordinatorProvider.overrideWith((ref) => null),
          appConfigProvider.overrideWithValue(
            testConfig(anonKey: 'sb_publishable_test'),
          ),
          appSessionProvider.overrideWith(
            (ref) => const AppSessionReady(user: user, business: business),
          ),
          authRepositoryProvider.overrideWith(
            (ref) => FakeAuthRepository(user: user),
          ),
          transactionRepositoryProvider.overrideWith(
            (ref) => FakeTransactionRepository(),
          ),
          obligationRepositoryProvider.overrideWith(
            (ref) => FakeObligationRepository(),
          ),
          productRepositoryProvider.overrideWith(
            (ref) => FakeProductRepository(),
          ),
        ],
        child: MaterialApp(
          theme: KgweboTheme.light(),
          home: const SyncQueueScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Nothing waiting to sync'), findsOneWidget);
  });

  testWidgets('failed operations show text status and a retry action', (
    tester,
  ) async {
    final database = KgweboDatabase.memory();
    addTearDown(database.close);
    final store = OutboxStore(database, idGenerator: () => 'op-fail');
    final payload = CreateTransactionPayload.fromDraft(
      currencyCode: 'BWP',
      draft: TransactionDraft(
        type: MoneyMovementType.sale,
        amountText: '50.00',
        occurredOn: DateTime(2026, 10, 21),
        category: 'goods',
        paymentMethod: PaymentMethod.cash,
        paymentStatus: PaymentStatus.paid,
        idempotencyKey: 'dddddddd-dddd-dddd-dddd-dddddddddddd',
      ),
    );
    await store.enqueue(
      ownerId: user.id,
      businessId: business.id,
      operationType: OutboxOperationTypes.createTransactionV1,
      payloadJson: payload.encode(),
      idempotencyKey: payload.idempotencyKey,
    );
    await store.markPermanent(
      operationId: 'op-fail',
      ownerId: user.id,
      businessId: business.id,
      error: const AuthFailure('The server rejected this sale.'),
      now: DateTime.utc(2026, 10, 21),
      attemptCount: 1,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          kgweboDatabaseProvider.overrideWith((ref) => database),
          syncCoordinatorProvider.overrideWith((ref) => null),
          appConfigProvider.overrideWithValue(
            testConfig(anonKey: 'sb_publishable_test'),
          ),
          appSessionProvider.overrideWith(
            (ref) => const AppSessionReady(user: user, business: business),
          ),
          authRepositoryProvider.overrideWith(
            (ref) => FakeAuthRepository(user: user),
          ),
          transactionRepositoryProvider.overrideWith(
            (ref) => FakeTransactionRepository(),
          ),
          obligationRepositoryProvider.overrideWith(
            (ref) => FakeObligationRepository(),
          ),
          productRepositoryProvider.overrideWith(
            (ref) => FakeProductRepository(),
          ),
        ],
        child: MaterialApp(
          theme: KgweboTheme.light(),
          home: const SyncQueueScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Action required'), findsWidgets);
    expect(find.textContaining('server rejected'), findsOneWidget);
    expect(find.text('Retry this change'), findsOneWidget);
    expect(find.byType(KgweboSyncStatusLabel), findsOneWidget);
  });

  testWidgets('status labels include text not only colour', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: KgweboTheme.light(),
        home: const Scaffold(
          body: KgweboSyncStatusLabel(state: OutboxState.pending),
        ),
      ),
    );
    expect(find.text('Waiting to sync'), findsOneWidget);
    expect(find.byIcon(Icons.schedule_outlined), findsOneWidget);
  });
}
