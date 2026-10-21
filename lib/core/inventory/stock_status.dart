enum StockAvailability { inStock, lowStock, outOfStock }

/// Zero stock is always out of stock, even when the low-stock threshold is 0.
StockAvailability stockAvailability({
  required int quantityMilli,
  int? lowStockThresholdMilli,
}) {
  if (quantityMilli <= 0) {
    return StockAvailability.outOfStock;
  }
  if (lowStockThresholdMilli != null &&
      quantityMilli <= lowStockThresholdMilli) {
    return StockAvailability.lowStock;
  }
  return StockAvailability.inStock;
}
