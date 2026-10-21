import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/kgwebo_spacing.dart';
import '../../../core/inventory/quantity_formatter.dart';
import '../../../core/inventory/unit_of_measure.dart';
import '../../../core/money/money_formatter.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../shared/widgets/kgwebo_button.dart';
import '../../../shared/widgets/kgwebo_empty_state.dart';
import '../../../shared/widgets/kgwebo_soft_card.dart';
import '../../../shared/widgets/kgwebo_status_banner.dart';
import '../../../shared/widgets/kgwebo_text_field.dart';
import '../../authentication/application/session_controller.dart';
import '../../authentication/domain/app_session.dart';
import '../../authentication/domain/auth_failure.dart';
import '../application/product_tick.dart';
import '../application/product_validators.dart';
import '../domain/product_draft.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.productId});

  final String? productId;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _name = TextEditingController();
  final _sku = TextEditingController();
  final _description = TextEditingController();
  final _sellingPrice = TextEditingController();
  final _unitCost = TextEditingController();
  final _threshold = TextEditingController();
  final _opening = TextEditingController();
  final _openingCost = TextEditingController();
  late final String _openingIdempotencyKey;
  UnitOfMeasure _unit = UnitOfMeasure.each;
  bool _isActive = true;
  ProductFieldErrors _errors = const ProductFieldErrors();
  bool _saving = false;
  bool _loadingExisting = false;
  bool _allowPop = false;
  bool _hydrated = false;
  String? _error;
  String? _existingId;

  bool get _isEdit => _existingId != null;

  @override
  void initState() {
    super.initState();
    _openingIdempotencyKey = const Uuid().v4();
    _existingId = widget.productId;
    if (widget.productId != null) {
      _loadingExisting = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
    } else {
      _hydrated = true;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _sku.dispose();
    _description.dispose();
    _sellingPrice.dispose();
    _unitCost.dispose();
    _threshold.dispose();
    _opening.dispose();
    _openingCost.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    final session = ref.read(appSessionProvider);
    if (session is! AppSessionReady) {
      setState(() {
        _loadingExisting = false;
        _error = 'Sign in to edit a saved product.';
      });
      return;
    }
    try {
      final existing = await ref
          .read(productRepositoryProvider)
          .findById(
            ownerId: session.user.id,
            businessId: session.business.id,
            productId: widget.productId!,
          );
      if (!mounted) {
        return;
      }
      if (existing == null) {
        setState(() {
          _loadingExisting = false;
          _error = 'This product could not be loaded.';
        });
        return;
      }
      _name.text = existing.name;
      _sku.text = existing.sku ?? '';
      _description.text = existing.description ?? '';
      _sellingPrice.text = _moneyText(existing.sellingPriceMinor);
      _unitCost.text =
          existing.unitCostMinor == null
              ? ''
              : _moneyText(existing.unitCostMinor!);
      _threshold.text =
          existing.lowStockThresholdMilli == null
              ? ''
              : QuantityFormatter.format(existing.lowStockThresholdMilli!);
      setState(() {
        _unit = existing.unitOfMeasure;
        _isActive = existing.isActive;
        _existingId = existing.id;
        _loadingExisting = false;
        _hydrated = true;
      });
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingExisting = false;
        _error = error.message;
      });
    }
  }

  String _moneyText(int minor) {
    return MoneyFormatter.formatMinor(
      minor,
      currencyCode: 'BWP',
      group: false,
    ).replaceFirst('P ', '');
  }

  ProductDraft _draft() {
    return ProductDraft(
      name: _name.text,
      sku: _sku.text,
      description: _description.text,
      sellingPriceText: _sellingPrice.text,
      unitCostText: _unitCost.text,
      lowStockThresholdText: _threshold.text,
      openingQuantityText: _isEdit ? '' : _opening.text,
      openingUnitCostText: _isEdit ? '' : _openingCost.text,
      openingIdempotencyKey: _openingIdempotencyKey,
      unitOfMeasure: _unit,
      isActive: _isActive,
      existingId: _existingId,
    );
  }

  bool get _isDirty {
    if (!_hydrated) {
      return false;
    }
    return _name.text.trim().isNotEmpty ||
        _sku.text.trim().isNotEmpty ||
        _sellingPrice.text.trim().isNotEmpty;
  }

  Future<bool> _confirmDiscard() async {
    if (!_isDirty || _saving) {
      return true;
    }
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Discard unsaved changes?'),
            content: const Text(
              'This product has not been saved. Leave without saving?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Keep editing'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Discard'),
              ),
            ],
          ),
    );
    return shouldDiscard ?? false;
  }

  void _leave(NavigatorState navigator, {bool saved = false}) {
    setState(() => _allowPop = true);
    navigator.pop(saved);
  }

  Future<void> _cancel() async {
    final navigator = Navigator.of(context);
    final shouldLeave = await _confirmDiscard();
    if (!shouldLeave || !mounted) {
      return;
    }
    _leave(navigator);
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }
    final errors = validateProductDraft(_draft());
    setState(() {
      _errors = errors;
      _error = null;
    });
    if (errors.hasErrors) {
      return;
    }
    final session = ref.read(appSessionProvider);
    if (session is! AppSessionReady) {
      setState(() => _error = 'Sign in to save this product.');
      return;
    }
    setState(() => _saving = true);
    try {
      final repository = ref.read(productRepositoryProvider);
      if (_isEdit) {
        await repository.update(
          ownerId: session.user.id,
          businessId: session.business.id,
          draft: _draft(),
        );
      } else {
        await repository.create(
          ownerId: session.user.id,
          businessId: session.business.id,
          draft: _draft(),
        );
      }
      if (!mounted) {
        return;
      }
      bumpProductTick(ref);
      _leave(Navigator.of(context), saved: true);
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _saving = false;
        _error = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(appSessionProvider);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return PopScope(
      canPop: _allowPop || !_hydrated || !_isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        final navigator = Navigator.of(context);
        final shouldLeave = await _confirmDiscard();
        if (!shouldLeave || !mounted) {
          return;
        }
        _leave(navigator);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEdit ? 'Edit product' : 'Add a product'),
          actions: [
            TextButton(
              onPressed: _saving ? null : _cancel,
              child: const Text('Cancel'),
            ),
          ],
        ),
        body: SafeArea(
          child: KgweboFilledBody(child: _buildBody(session, bottomInset)),
        ),
      ),
    );
  }

  Widget _buildBody(AppSession session, double bottomInset) {
    if (session is AppSessionPreview) {
      return const KgweboEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'Preview cannot save products',
        message:
            'Sign in to catalogue products against your business. Writes are online-only in this phase.',
      );
    }
    if (session is! AppSessionReady) {
      return const KgweboEmptyState(
        icon: Icons.lock_outline,
        title: 'Sign in to continue',
        message: 'Products are saved to your authorised business only.',
      );
    }
    if (_loadingExisting) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        KgweboSpacing.md,
        KgweboSpacing.md,
        KgweboSpacing.md,
        KgweboSpacing.xl + bottomInset,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KgweboStatusBanner(
            tone: KgweboBannerTone.info,
            message:
                'Current prices can change later. Past sales keep the price and cost that were recorded at the time.',
          ),
          const SizedBox(height: KgweboSpacing.md),
          if (_error != null) ...[
            KgweboStatusBanner(
              tone: KgweboBannerTone.warning,
              message: _error!,
            ),
            const SizedBox(height: KgweboSpacing.md),
          ],
          KgweboSoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                KgweboTextField(
                  controller: _name,
                  label: 'Product name',
                  hint: 'Tomatoes',
                  textCapitalization: TextCapitalization.sentences,
                  errorText: _errors.name,
                  enabled: !_saving,
                ),
                const SizedBox(height: KgweboSpacing.md),
                KgweboTextField(
                  controller: _sku,
                  label: 'SKU or product code (optional)',
                  hint: 'TOM-1',
                  errorText: _errors.sku,
                  enabled: !_saving,
                ),
                const SizedBox(height: KgweboSpacing.md),
                KgweboTextField(
                  controller: _description,
                  label: 'Description (optional)',
                  errorText: _errors.description,
                  enabled: !_saving,
                ),
                const SizedBox(height: KgweboSpacing.md),
                DropdownButtonFormField<UnitOfMeasure>(
                  isExpanded: true,
                  value: _unit,
                  decoration: const InputDecoration(
                    labelText: 'Unit of measure',
                  ),
                  items: [
                    for (final unit in UnitOfMeasure.values)
                      DropdownMenuItem(value: unit, child: Text(unit.label)),
                  ],
                  onChanged:
                      _saving
                          ? null
                          : (value) => setState(() => _unit = value ?? _unit),
                ),
                const SizedBox(height: KgweboSpacing.md),
                KgweboTextField(
                  controller: _sellingPrice,
                  label: 'Selling price',
                  hint: '12.50',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  errorText: _errors.sellingPrice,
                  enabled: !_saving,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                ),
                const SizedBox(height: KgweboSpacing.md),
                KgweboTextField(
                  controller: _unitCost,
                  label: 'Cost price (optional)',
                  hint: '8.00',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  errorText: _errors.unitCost,
                  enabled: !_saving,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                ),
                const SizedBox(height: KgweboSpacing.md),
                KgweboTextField(
                  controller: _threshold,
                  label: 'Low-stock threshold (optional)',
                  hint: _unit.allowsFraction ? '2.5' : '5',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  errorText: _errors.lowStockThreshold,
                  enabled: !_saving,
                ),
                if (!_isEdit) ...[
                  const SizedBox(height: KgweboSpacing.md),
                  KgweboTextField(
                    controller: _opening,
                    label: 'Opening stock (optional)',
                    hint: _unit.allowsFraction ? '10.5' : '10',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    errorText: _errors.openingQuantity,
                    enabled: !_saving,
                  ),
                  const SizedBox(height: KgweboSpacing.md),
                  KgweboTextField(
                    controller: _openingCost,
                    label: 'Opening stock cost (optional)',
                    hint: '8.00',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    errorText: _errors.openingUnitCost,
                    enabled: !_saving,
                  ),
                ],
                if (_isEdit) ...[
                  const SizedBox(height: KgweboSpacing.md),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active product'),
                    subtitle: const Text(
                      'Turn this off to archive. Historical stock movements stay in place.',
                    ),
                    value: _isActive,
                    onChanged:
                        _saving
                            ? null
                            : (value) => setState(() => _isActive = value),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: KgweboSpacing.lg),
          KgweboButton(
            label: _isEdit ? 'Save product' : 'Save product',
            expanded: true,
            isLoading: _saving,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}
