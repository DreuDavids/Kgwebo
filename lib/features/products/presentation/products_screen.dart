import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme/kgwebo_spacing.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../shared/widgets/kgwebo_empty_state.dart';
import '../../../shared/widgets/kgwebo_loading_state.dart';
import '../../../shared/widgets/kgwebo_status_banner.dart';
import '../../../shared/widgets/kgwebo_text_field.dart';
import '../../authentication/application/session_controller.dart';
import '../../authentication/domain/app_session.dart';
import '../application/products_controller.dart';
import '../domain/product_query.dart';
import 'widgets/inventory_overview.dart';
import 'widgets/product_list_item.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  late final TextEditingController _search;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(appSessionProvider);
    final state = ref.watch(productsControllerProvider);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final currency =
        session is AppSessionReady ? session.business.currencyCode : 'BWP';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            tooltip: 'Add product',
            onPressed: () => context.pushNamed(AppRoutes.productNewName),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SafeArea(
        child: KgweboFilledBody(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  KgweboSpacing.md,
                  KgweboSpacing.sm,
                  KgweboSpacing.md,
                  0,
                ),
                child: KgweboTextField(
                  controller: _search,
                  label: 'Search name or code',
                  onChanged: (value) {
                    _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 280), () {
                      ref
                          .read(productsControllerProvider.notifier)
                          .applySearch(value);
                    });
                  },
                ),
              ),
              const SizedBox(height: KgweboSpacing.sm),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: KgweboSpacing.md,
                ),
                child: Row(
                  children: [
                    for (final filter in ProductListFilter.values) ...[
                      FilterChip(
                        key: ValueKey('product-filter-${filter.name}'),
                        label: Text(_filterLabel(filter)),
                        selected: state.filter == filter,
                        onSelected: (_) {
                          ref
                              .read(productsControllerProvider.notifier)
                              .applyFilter(filter);
                        },
                      ),
                      const SizedBox(width: KgweboSpacing.xs),
                    ],
                  ],
                ),
              ),
              Expanded(child: _body(session, state, currency, bottomInset)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(
    AppSession session,
    ProductsViewState state,
    String currency,
    double bottomInset,
  ) {
    if (session is AppSessionPreview) {
      return const KgweboEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'Preview cannot save stock',
        message:
            'Sign in to catalogue products and record stock movements. Writes are online-only in this phase.',
      );
    }
    if (state.loading && state.snapshot == null) {
      return const KgweboLoadingState(message: 'Loading products');
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(productsControllerProvider.notifier).refresh(),
      child: ListView(
        cacheExtent: 800,
        padding: EdgeInsets.fromLTRB(
          KgweboSpacing.md,
          KgweboSpacing.sm,
          KgweboSpacing.md,
          KgweboSpacing.xl + bottomInset + 72,
        ),
        children: [
          if (state.isStale)
            const Padding(
              padding: EdgeInsets.only(bottom: KgweboSpacing.md),
              child: KgweboStatusBanner(
                tone: KgweboBannerTone.warning,
                message:
                    'Showing saved stock from this device. It may not include the latest changes.',
              ),
            )
          else if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: KgweboSpacing.md),
              child: KgweboStatusBanner(
                tone: KgweboBannerTone.warning,
                message: state.error!,
              ),
            ),
          const KgweboStatusBanner(
            tone: KgweboBannerTone.info,
            message:
                'Stock writes need a connection. They are not queued offline.',
          ),
          const SizedBox(height: KgweboSpacing.sm),
          InventoryOverview(insights: state.insights, currencyCode: currency),
          const SizedBox(height: KgweboSpacing.sm),
          if (state.items.isEmpty)
            KgweboEmptyState(
              icon: Icons.inventory_2_outlined,
              title:
                  state.snapshot?.items.isEmpty ?? true
                      ? 'No products yet'
                      : 'No products match this filter',
              message:
                  state.snapshot?.items.isEmpty ?? true
                      ? 'Add the goods you sell so you can track remaining stock and estimated value.'
                      : 'Try another search or filter.',
              actionLabel: 'Add product',
              onAction: () => context.pushNamed(AppRoutes.productNewName),
            )
          else
            for (final product in state.items) ...[
              ProductListItem(
                product: product,
                currencyCode: currency,
                onTap:
                    () => context.pushNamed(
                      AppRoutes.productDetailsName,
                      pathParameters: {'productId': product.id},
                    ),
              ),
              const SizedBox(height: KgweboSpacing.sm),
            ],
        ],
      ),
    );
  }

  String _filterLabel(ProductListFilter filter) {
    return switch (filter) {
      ProductListFilter.active => 'Active',
      ProductListFilter.lowStock => 'Low stock',
      ProductListFilter.outOfStock => 'Out of stock',
      ProductListFilter.archived => 'Archived',
      ProductListFilter.all => 'All',
    };
  }
}
