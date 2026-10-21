import '../../../core/inventory/stock_status.dart';
import '../domain/catalog_product.dart';
import '../domain/product_query.dart';

List<CatalogProduct> filterProducts(
  Iterable<CatalogProduct> products,
  ProductQuery query,
) {
  final search = query.search?.trim().toLowerCase() ?? '';
  return [
    for (final product in products)
      if (_matchesFilter(product, query.filter) &&
          _matchesSearch(product, search))
        product,
  ];
}

bool _matchesFilter(CatalogProduct product, ProductListFilter filter) {
  return switch (filter) {
    ProductListFilter.all => true,
    ProductListFilter.active => product.isActive,
    ProductListFilter.archived => !product.isActive,
    ProductListFilter.lowStock =>
      product.isActive && product.availability == StockAvailability.lowStock,
    ProductListFilter.outOfStock =>
      product.isActive && product.availability == StockAvailability.outOfStock,
  };
}

bool _matchesSearch(CatalogProduct product, String search) {
  if (search.isEmpty) {
    return true;
  }
  final sku = product.sku?.toLowerCase() ?? '';
  return product.name.toLowerCase().contains(search) || sku.contains(search);
}
