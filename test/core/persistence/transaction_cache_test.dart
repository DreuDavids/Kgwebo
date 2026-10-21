import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/ledger_entry.dart';
import 'package:kgwebo/core/persistence/kgwebo_database.dart';
import 'package:kgwebo/core/persistence/transaction_cache.dart';
import 'package:kgwebo/features/transactions/domain/transaction_query.dart';

import '../../helpers/fake_transactions.dart';

void main() {
  late KgweboDatabase database;
  late TransactionCache cache;

  setUp(() {
    database = KgweboDatabase.memory();
    cache = TransactionCache(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('schema version is 5', () {
    expect(database.schemaVersion, 5);
  });

  test('insert and read a confirmed transaction for the owner', () async {
    final sale = sampleSale();
    await cache.upsertConfirmed(sale);
    final loaded = await cache.findConfirmed(
      ownerId: 'user-1',
      businessId: 'biz-1',
      transactionId: sale.id,
    );
    expect(loaded, isNotNull);
    expect(loaded!.amountMinor, 50000);
    expect(loaded.type, MoneyMovementType.sale);
  });

  test('queries only the current owner and business', () async {
    await cache.upsertConfirmed(sampleSale());
    await cache.upsertConfirmed(
      sampleSale(id: 'tx-b', ownerId: 'user-b', businessId: 'biz-b'),
    );
    final listed = await cache.listConfirmed(
      ownerId: 'user-1',
      businessId: 'biz-1',
    );
    expect(listed, hasLength(1));
    expect(listed.single.id, 'tx-sale');
    expect(
      await cache.findConfirmed(
        ownerId: 'user-b',
        businessId: 'biz-1',
        transactionId: 'tx-sale',
      ),
      isNull,
    );
  });

  test(
    'failed replace is not this test; empty owner returns nothing',
    () async {
      await cache.upsertConfirmed(sampleSale());
      expect(
        await cache.listConfirmed(ownerId: '', businessId: 'biz-1'),
        isEmpty,
      );
    },
  );

  test('search filters category without mixing owners', () async {
    await cache.upsertConfirmed(sampleSale());
    await cache.upsertConfirmed(sampleSale(id: 'tx-2', amount: 10000));
    final listed = await cache.listConfirmed(
      ownerId: 'user-1',
      businessId: 'biz-1',
      query: const TransactionQuery(search: 'goods'),
    );
    expect(listed, hasLength(2));
    expect(
      await cache.listConfirmed(
        ownerId: 'user-b',
        businessId: 'biz-1',
        query: const TransactionQuery(search: 'goods'),
      ),
      isEmpty,
    );
  });
}
