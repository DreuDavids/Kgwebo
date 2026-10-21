enum ProductListFilter { active, lowStock, outOfStock, archived, all }

class ProductQuery {
  const ProductQuery({this.search, this.filter = ProductListFilter.active});

  final String? search;
  final ProductListFilter filter;
}
