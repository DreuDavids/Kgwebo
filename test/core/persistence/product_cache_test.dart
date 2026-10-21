import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/persistence/kgwebo_database.dart';
import 'package:kgwebo/core/persistence/product_cache.dart';
import 'package:kgwebo/features/authentication/domain/auth_failure.dart';
import 'package:kgwebo/features/products/data/cached_product_repository.dart';

import '../../helpers/fake_products.dart';

void main() {
  late KgweboDatabase database;
  late ProductCache cache;

  setUp(() {
    database = KgweboDatabase.memory();
    cache = ProductCache(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('insert and read a confirmed product for the owner', () async {
    await cache.upsertProduct(sampleProduct());
    final loaded = await cache.findProduct(
      ownerId: 'user-1',
      businessId: 'biz-1',
      productId: 'prod-1',
    );
    expect(loaded, isNotNull);
    expect(loaded!.name, 'Tomatoes');
    expect(loaded.stockQuantityMilli, 5000);
  });

  test('queries only the current owner and business', () async {
    await cache.upsertProduct(sampleProduct());
    await cache.upsertProduct(
      sampleProduct(id: 'prod-b', ownerId: 'user-b', businessId: 'biz-b'),
    );
    final listed = await cache.listProducts(
      ownerId: 'user-1',
      businessId: 'biz-1',
    );
    expect(listed, hasLength(1));
    expect(listed.single.id, 'prod-1');
  });

  test('failed refresh keeps the last confirmed products', () async {
    final remote = FakeProductRepository(products: [sampleProduct()]);
    final cached = CachedProductRepository(
      remote: remote,
      cache: cache,
      currentOwnerId: () => 'user-1',
    );
    await cached.listAllConfirmed(ownerId: 'user-1', businessId: 'biz-1');
    remote.failReads = const AuthFailure.network();
    final snapshot = await cached.listAllConfirmed(
      ownerId: 'user-1',
      businessId: 'biz-1',
    );
    expect(snapshot.isStale, isTrue);
    expect(snapshot.items.single.name, 'Tomatoes');
  });
}
