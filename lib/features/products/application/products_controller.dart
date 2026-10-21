import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/inventory/inventory_insights.dart';
import '../../authentication/application/session_controller.dart';
import '../../authentication/domain/app_session.dart';
import '../../authentication/domain/auth_failure.dart';
import '../domain/catalog_product.dart';
import '../domain/product_query.dart';
import '../domain/product_snapshot.dart';
import 'product_filters.dart';
import 'product_repository.dart';
import 'product_tick.dart';

class ProductsViewState {
  const ProductsViewState({
    this.loading = false,
    this.snapshot,
    this.error,
    this.search = '',
    this.filter = ProductListFilter.active,
  });

  final bool loading;
  final ProductListSnapshot? snapshot;
  final String? error;
  final String search;
  final ProductListFilter filter;

  List<CatalogProduct> get items {
    return filterProducts(
      snapshot?.items ?? const [],
      ProductQuery(search: search, filter: filter),
    );
  }

  InventoryInsights get insights {
    return InventoryInsights.fromProducts(snapshot?.items ?? const []);
  }

  bool get isStale => snapshot?.isStale ?? false;

  ProductsViewState copyWith({
    bool? loading,
    ProductListSnapshot? snapshot,
    String? error,
    String? search,
    ProductListFilter? filter,
    bool clearError = false,
  }) {
    return ProductsViewState(
      loading: loading ?? this.loading,
      snapshot: snapshot ?? this.snapshot,
      error: clearError ? null : (error ?? this.error),
      search: search ?? this.search,
      filter: filter ?? this.filter,
    );
  }
}

final inventoryAttentionProvider =
    FutureProvider.autoDispose<InventoryInsights>((ref) async {
      ref.watch(productTickProvider);
      final session = ref.watch(appSessionProvider);
      if (session is! AppSessionReady) {
        return const InventoryInsights(
          activeCount: 0,
          lowStockCount: 0,
          outOfStockCount: 0,
          missingCostCount: 0,
          estimatedValueMinor: 0,
          restockProductIds: [],
        );
      }
      final snapshot = await ref
          .watch(productRepositoryProvider)
          .listAllConfirmed(
            ownerId: session.user.id,
            businessId: session.business.id,
          );
      return InventoryInsights.fromProducts(snapshot.items);
    });

final productsControllerProvider =
    StateNotifierProvider.autoDispose<ProductsController, ProductsViewState>((
      ref,
    ) {
      ref.watch(productTickProvider);
      return ProductsController(
        session: ref.watch(appSessionProvider),
        repository: ref.watch(productRepositoryProvider),
      );
    });

class ProductsController extends StateNotifier<ProductsViewState> {
  ProductsController({
    required AppSession session,
    required ProductRepository repository,
  }) : _session = session,
       _repository = repository,
       super(const ProductsViewState(loading: true)) {
    _load();
  }

  final AppSession _session;
  final ProductRepository _repository;

  Future<void> _load() async {
    final ready = _session;
    if (ready is! AppSessionReady) {
      state = const ProductsViewState();
      return;
    }
    state = state.copyWith(loading: true, clearError: true);
    try {
      final snapshot = await _repository.listAllConfirmed(
        ownerId: ready.user.id,
        businessId: ready.business.id,
      );
      if (!mounted) {
        return;
      }
      state = state.copyWith(
        loading: false,
        snapshot: snapshot,
        error: snapshot.refreshError,
      );
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }
      state = state.copyWith(loading: false, error: error.message);
    }
  }

  Future<void> refresh() => _load();

  void applySearch(String search) {
    state = state.copyWith(search: search);
  }

  void applyFilter(ProductListFilter filter) {
    state = state.copyWith(filter: filter);
  }
}
