import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/business_calendar.dart';
import 'package:kgwebo/core/finance/dashboard_period.dart';
import 'package:kgwebo/core/finance/ledger_entry.dart';
import 'package:kgwebo/features/authentication/domain/app_session.dart';
import 'package:kgwebo/features/authentication/domain/auth_user.dart';
import 'package:kgwebo/features/onboarding/domain/business_profile.dart';
import 'package:kgwebo/features/transactions/application/transactions_controller.dart';
import 'package:kgwebo/features/transactions/domain/business_transaction.dart';
import 'package:kgwebo/features/transactions/domain/payment_method.dart';

import '../../helpers/fake_transactions.dart';

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

  BusinessTransaction tx({
    required String id,
    required MoneyMovementType type,
    required String category,
    required DateTime occurredAt,
    int amount = 1000,
  }) {
    return BusinessTransaction(
      id: id,
      businessId: 'biz-1',
      ownerId: 'user-1',
      createdBy: 'user-1',
      idempotencyKey: 'key-$id',
      type: type,
      amountMinor: amount,
      currencyCode: 'BWP',
      category: category,
      description: id,
      occurredAt: occurredAt,
      paymentMethod: PaymentMethod.cash,
      paymentStatus: PaymentStatus.paid,
      createdAt: occurredAt,
      updatedAt: occurredAt,
    );
  }

  Future<TransactionsController> controllerWith(
    FakeTransactionRepository repository,
  ) async {
    final controller = TransactionsController(
      session: const AppSessionReady(user: user, business: business),
      repository: repository,
    );
    await Future<void>.delayed(Duration.zero);
    return controller;
  }

  test('type, category and search filters work together', () async {
    final october = BusinessCalendar.utcFromGaborone(
      year: 2026,
      month: 10,
      day: 10,
    );
    final repository =
        FakeTransactionRepository()
          ..items.addAll([
            tx(
              id: 'goods',
              type: MoneyMovementType.sale,
              category: 'goods',
              occurredAt: october,
            ),
            tx(
              id: 'services',
              type: MoneyMovementType.sale,
              category: 'services',
              occurredAt: october,
            ),
            tx(
              id: 'rent',
              type: MoneyMovementType.expense,
              category: 'rent',
              occurredAt: october,
            ),
          ]);
    final controller = await controllerWith(repository);
    expect(controller.state.items, hasLength(3));

    await controller.applyTypeFilter(MoneyMovementType.sale);
    expect(controller.state.items.map((item) => item.id), [
      'services',
      'goods',
    ]);

    await controller.applyCategoryFilter('goods');
    expect(controller.state.items.map((item) => item.id), ['goods']);

    await controller.applySearch('nope');
    expect(controller.state.items, isEmpty);

    await controller.applySearch('goods');
    expect(controller.state.items.map((item) => item.id), ['goods']);

    await controller.clearFilters();
    expect(controller.state.hasActiveFilters, isFalse);
    expect(controller.state.search, 'goods');
    expect(controller.state.items.map((item) => item.id), ['goods']);
  });

  test('changing filters resets pagination and loadMore appends', () async {
    final october = BusinessCalendar.utcFromGaborone(
      year: 2026,
      month: 10,
      day: 10,
    );
    final repository =
        FakeTransactionRepository()
          ..items.addAll([
            for (var i = 0; i < 12; i++)
              tx(
                id: 'sale-$i',
                type: MoneyMovementType.sale,
                category: 'goods',
                occurredAt: october.subtract(Duration(minutes: i)),
              ),
          ]);
    final controller = await controllerWith(repository);
    await controller.applyTypeFilter(MoneyMovementType.sale);
    expect(controller.state.items, hasLength(12));

    repository.items.add(
      tx(
        id: 'sale-new',
        type: MoneyMovementType.sale,
        category: 'goods',
        occurredAt: october.add(const Duration(hours: 1)),
      ),
    );
    await controller.applyTypeFilter(MoneyMovementType.sale);
    expect(controller.state.items.first.id, 'sale-new');
    expect(controller.state.snapshot?.hasMore, isFalse);
  });

  test('loadMore appends the next page instead of replacing it', () async {
    final base = BusinessCalendar.utcFromGaborone(
      year: 2026,
      month: 10,
      day: 20,
    );
    final repository =
        FakeTransactionRepository()
          ..items.addAll([
            for (var i = 0; i < 60; i++)
              tx(
                id: 'p-$i',
                type: MoneyMovementType.sale,
                category: 'goods',
                occurredAt: base.subtract(Duration(minutes: i)),
              ),
          ]);
    final controller = await controllerWith(repository);
    expect(controller.state.items, hasLength(50));
    expect(controller.state.hasMore, isTrue);
    final firstPage = controller.state.items.map((item) => item.id).toList();
    await controller.loadMore();
    expect(controller.state.items, hasLength(60));
    expect(
      controller.state.items.take(50).map((item) => item.id).toList(),
      firstPage,
    );
  });

  test('period filter uses Gaborone bounds and does not mutate rows', () async {
    final repository =
        FakeTransactionRepository()
          ..items.addAll([
            tx(
              id: 'oct',
              type: MoneyMovementType.sale,
              category: 'goods',
              occurredAt: BusinessCalendar.utcFromGaborone(
                year: 2026,
                month: 10,
                day: 15,
              ),
            ),
            tx(
              id: 'nov',
              type: MoneyMovementType.sale,
              category: 'goods',
              occurredAt: BusinessCalendar.utcFromGaborone(
                year: 2026,
                month: 11,
                day: 1,
              ),
            ),
          ]);
    final controller = await controllerWith(repository);
    await controller.applyPeriodFilter(
      DashboardPeriodKind.custom,
      customStart: DateTime(2026, 10, 1),
      customEnd: DateTime(2026, 10, 31),
    );
    expect(controller.state.items.map((item) => item.id), ['oct']);
    expect(repository.items, hasLength(2));
  });
}
