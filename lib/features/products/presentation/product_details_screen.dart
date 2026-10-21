import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../../app/theme/kgwebo_colors.dart';
import '../../../app/theme/kgwebo_spacing.dart';
import '../../../core/inventory/quantity_formatter.dart';
import '../../../core/inventory/stock_status.dart';
import '../../../core/inventory/unit_of_measure.dart';
import '../../../core/money/money_formatter.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../shared/widgets/kgwebo_button.dart';
import '../../../shared/widgets/kgwebo_empty_state.dart';
import '../../../shared/widgets/kgwebo_soft_card.dart';
import '../../../shared/widgets/kgwebo_status_banner.dart';
import '../../authentication/application/session_controller.dart';
import '../../authentication/domain/app_session.dart';
import '../../authentication/domain/auth_failure.dart';
import '../application/product_tick.dart';
import '../domain/catalog_product.dart';
import '../domain/stock_movement.dart';
import '../domain/stock_movement_type.dart';
import '../domain/product_snapshot.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  const ProductDetailsScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  CatalogProduct? _product;
  StockMovementListSnapshot? _movements;
  String? _error;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final session = ref.read(appSessionProvider);
    if (session is! AppSessionReady) {
      setState(() {
        _loading = false;
        _error = 'Sign in to view this product.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repository = ref.read(productRepositoryProvider);
      final product = await repository.findById(
        ownerId: session.user.id,
        businessId: session.business.id,
        productId: widget.productId,
      );
      final movements = await repository.listMovements(
        ownerId: session.user.id,
        businessId: session.business.id,
        productId: widget.productId,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _product = product;
        _movements = movements;
        _loading = false;
        _error = movements.refreshError;
      });
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = error.message;
      });
    }
  }

  Future<void> _archive() async {
    final session = ref.read(appSessionProvider);
    final product = _product;
    if (session is! AppSessionReady || product == null || _busy) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Archive this product?'),
            content: const Text(
              'It will leave the active list. Stock history stays in place.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Keep'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Archive'),
              ),
            ],
          ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(productRepositoryProvider)
          .archive(
            ownerId: session.user.id,
            businessId: session.business.id,
            productId: product.id,
          );
      bumpProductTick(ref);
      await _load();
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _error = error.message;
      });
      return;
    }
    if (mounted) {
      setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final session = ref.read(appSessionProvider);
    final product = _product;
    if (session is! AppSessionReady || product == null || _busy) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete this product?'),
            content: const Text(
              'Only products without stock history can be deleted. Otherwise archive them.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Keep'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(productRepositoryProvider)
          .delete(
            ownerId: session.user.id,
            businessId: session.business.id,
            productId: product.id,
          );
      if (!mounted) {
        return;
      }
      bumpProductTick(ref);
      Navigator.of(context).pop();
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _error = error.message;
      });
    }
  }

  void _openStock(StockMovementType type) {
    context.pushNamed(
      AppRoutes.productStockName,
      pathParameters: {'productId': widget.productId},
      extra: type,
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(appSessionProvider);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final currency =
        session is AppSessionReady ? session.business.currencyCode : 'BWP';
    return Scaffold(
      appBar: AppBar(
        title: Text(_product?.name ?? 'Product'),
        actions: [
          IconButton(
            tooltip: 'Edit product',
            onPressed:
                _product == null
                    ? null
                    : () => context.pushNamed(
                      AppRoutes.productEditName,
                      pathParameters: {'productId': widget.productId},
                    ),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: KgweboFilledBody(
          child: _buildBody(session, currency, bottomInset),
        ),
      ),
    );
  }

  Widget _buildBody(AppSession session, String currency, double bottomInset) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final product = _product;
    if (product == null) {
      return KgweboEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'Product not found',
        message: _error ?? 'This product could not be loaded.',
      );
    }
    final stock = QuantityFormatter.formatWithUnit(
      product.stockQuantityMilli,
      product.unitOfMeasure.label,
    );
    return ListView(
      padding: EdgeInsets.fromLTRB(
        KgweboSpacing.md,
        KgweboSpacing.md,
        KgweboSpacing.md,
        KgweboSpacing.xl + bottomInset,
      ),
      children: [
        if (_movements?.isStale ?? false)
          const Padding(
            padding: EdgeInsets.only(bottom: KgweboSpacing.md),
            child: KgweboStatusBanner(
              tone: KgweboBannerTone.warning,
              message:
                  'Showing saved stock history from this device. It may not include the latest changes.',
            ),
          ),
        if (_error != null) ...[
          KgweboStatusBanner(tone: KgweboBannerTone.warning, message: _error!),
          const SizedBox(height: KgweboSpacing.md),
        ],
        KgweboSoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name, style: Theme.of(context).textTheme.titleLarge),
              if (product.sku != null) ...[
                const SizedBox(height: KgweboSpacing.xs),
                Text(
                  product.sku!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: KgweboColors.inkMuted),
                ),
              ],
              const SizedBox(height: KgweboSpacing.md),
              Text('Available stock $stock'),
              Text(_statusLabel(product.availability)),
              const SizedBox(height: KgweboSpacing.sm),
              Text(
                'Current selling price ${MoneyFormatter.formatMinor(product.sellingPriceMinor, currencyCode: currency)}',
              ),
              Text(
                product.unitCostMinor == null
                    ? 'Current cost is not recorded. Estimated value is excluded.'
                    : 'Current cost ${MoneyFormatter.formatMinor(product.unitCostMinor!, currencyCode: currency)}. This is not the historical cost of past sales.',
              ),
              if (!product.isActive) ...[
                const SizedBox(height: KgweboSpacing.sm),
                const Text('This product is archived.'),
              ],
            ],
          ),
        ),
        const SizedBox(height: KgweboSpacing.md),
        Wrap(
          spacing: KgweboSpacing.sm,
          runSpacing: KgweboSpacing.sm,
          children: [
            KgweboButton(
              label: 'Receive stock',
              onPressed: () => _openStock(StockMovementType.received),
            ),
            KgweboButton(
              label: 'Adjust',
              variant: KgweboButtonVariant.secondary,
              onPressed: () => _openStock(StockMovementType.adjustmentIncrease),
            ),
            KgweboButton(
              label: 'Return',
              variant: KgweboButtonVariant.secondary,
              onPressed: () => _openStock(StockMovementType.customerReturn),
            ),
            KgweboButton(
              label: 'Damage',
              variant: KgweboButtonVariant.secondary,
              onPressed: () => _openStock(StockMovementType.damaged),
            ),
          ],
        ),
        const SizedBox(height: KgweboSpacing.lg),
        Text('Stock history', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: KgweboSpacing.sm),
        if (_movements?.items.isEmpty ?? true)
          const KgweboEmptyState(
            icon: Icons.history,
            title: 'No stock movements yet',
            message:
                'Receive opening stock or restock so remaining units are explained by a ledger.',
          )
        else
          for (final movement in _movements!.items)
            Padding(
              padding: const EdgeInsets.only(bottom: KgweboSpacing.sm),
              child: _MovementTile(movement: movement, currencyCode: currency),
            ),
        const SizedBox(height: KgweboSpacing.lg),
        KgweboButton(
          label: 'Archive product',
          variant: KgweboButtonVariant.secondary,
          onPressed: _busy ? null : _archive,
        ),
        const SizedBox(height: KgweboSpacing.sm),
        KgweboButton(
          label: 'Delete product',
          variant: KgweboButtonVariant.text,
          onPressed: _busy ? null : _delete,
        ),
      ],
    );
  }

  String _statusLabel(StockAvailability availability) {
    return switch (availability) {
      StockAvailability.inStock => 'In stock',
      StockAvailability.lowStock => 'Low stock',
      StockAvailability.outOfStock => 'Out of stock',
    };
  }
}

class _MovementTile extends StatelessWidget {
  const _MovementTile({required this.movement, required this.currencyCode});

  final StockMovement movement;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final qty = QuantityFormatter.format(movement.quantityMilli);
    final delta = QuantityFormatter.format(movement.quantityDeltaMilli);
    final when = DateFormat.yMMMd().add_jm().format(
      movement.createdAt.toLocal(),
    );
    return KgweboSoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            movement.type.label,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            '$qty units · stock change $delta · remaining ${QuantityFormatter.format(movement.resultingQuantityMilli)}',
          ),
          if (movement.unitCostMinor != null)
            Text(
              'Recorded unit cost ${MoneyFormatter.formatMinor(movement.unitCostMinor!, currencyCode: currencyCode)}',
            ),
          if (movement.reason != null) Text(movement.reason!),
          Text(
            when,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: KgweboColors.inkMuted),
          ),
        ],
      ),
    );
  }
}
