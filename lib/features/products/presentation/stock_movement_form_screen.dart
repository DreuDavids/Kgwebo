import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/kgwebo_spacing.dart';
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
import '../domain/stock_movement_draft.dart';
import '../domain/stock_movement_type.dart';

class StockMovementFormScreen extends ConsumerStatefulWidget {
  const StockMovementFormScreen({
    super.key,
    required this.productId,
    required this.type,
  });

  final String productId;
  final StockMovementType type;

  @override
  ConsumerState<StockMovementFormScreen> createState() =>
      _StockMovementFormScreenState();
}

class _StockMovementFormScreenState
    extends ConsumerState<StockMovementFormScreen> {
  final _quantity = TextEditingController();
  final _cost = TextEditingController();
  final _reason = TextEditingController();
  final _notes = TextEditingController();
  late final String _idempotencyKey;
  late StockMovementType _type;
  StockMovementFieldErrors _errors = const StockMovementFieldErrors();
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _idempotencyKey = const Uuid().v4();
    _type =
        widget.type == StockMovementType.adjustmentDecrease
            ? StockMovementType.adjustmentIncrease
            : widget.type;
  }

  @override
  void dispose() {
    _quantity.dispose();
    _cost.dispose();
    _reason.dispose();
    _notes.dispose();
    super.dispose();
  }

  StockMovementDraft _draft() {
    return StockMovementDraft(
      type: _type,
      quantityText: _quantity.text,
      unitCostText: _cost.text,
      reason: _reason.text,
      notes: _notes.text,
      idempotencyKey: _idempotencyKey,
    );
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }
    final errors = validateStockMovementDraft(_draft());
    setState(() {
      _errors = errors;
      _error = null;
    });
    if (errors.hasErrors) {
      return;
    }
    if (_type.requiresReason ||
        _type == StockMovementType.adjustmentIncrease ||
        _type == StockMovementType.adjustmentDecrease ||
        _type == StockMovementType.damaged) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Confirm this stock change?'),
              content: Text(
                'This will change available stock for this product. ${_onlineCopy()}',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Confirm'),
                ),
              ],
            ),
      );
      if (confirmed != true || !mounted) {
        return;
      }
    }
    final session = ref.read(appSessionProvider);
    if (session is! AppSessionReady) {
      setState(() => _error = 'Sign in to record stock movements.');
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(productRepositoryProvider)
          .recordMovement(
            ownerId: session.user.id,
            businessId: session.business.id,
            productId: widget.productId,
            draft: _draft(),
          );
      if (!mounted) {
        return;
      }
      bumpProductTick(ref);
      Navigator.of(context).pop(true);
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

  String _onlineCopy() {
    return 'Stock changes need an internet connection.';
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(appSessionProvider);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Scaffold(
      appBar: AppBar(title: Text(_type.label)),
      body: SafeArea(
        child: KgweboFilledBody(child: _body(session, bottomInset)),
      ),
    );
  }

  Widget _body(AppSession session, double bottomInset) {
    if (session is AppSessionPreview) {
      return KgweboEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'Preview cannot change stock',
        message: _onlineCopy(),
      );
    }
    if (session is! AppSessionReady) {
      return const KgweboEmptyState(
        icon: Icons.lock_outline,
        title: 'Sign in to continue',
        message: 'Stock movements are saved to your authorised business only.',
      );
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
          KgweboStatusBanner(
            tone: KgweboBannerTone.info,
            message: _helpText(_type),
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
                if (widget.type == StockMovementType.adjustmentIncrease ||
                    widget.type == StockMovementType.adjustmentDecrease)
                  DropdownButtonFormField<StockMovementType>(
                    isExpanded: true,
                    value:
                        _type == StockMovementType.adjustmentDecrease
                            ? StockMovementType.adjustmentDecrease
                            : StockMovementType.adjustmentIncrease,
                    decoration: const InputDecoration(labelText: 'Adjustment'),
                    items: const [
                      DropdownMenuItem(
                        value: StockMovementType.adjustmentIncrease,
                        child: Text('Increase stock'),
                      ),
                      DropdownMenuItem(
                        value: StockMovementType.adjustmentDecrease,
                        child: Text('Decrease stock'),
                      ),
                    ],
                    onChanged:
                        _saving
                            ? null
                            : (value) => setState(
                              () =>
                                  _type =
                                      value ??
                                      StockMovementType.adjustmentIncrease,
                            ),
                  ),
                if (widget.type == StockMovementType.customerReturn)
                  DropdownButtonFormField<StockMovementType>(
                    isExpanded: true,
                    value: _type,
                    decoration: const InputDecoration(labelText: 'Return type'),
                    items: const [
                      DropdownMenuItem(
                        value: StockMovementType.customerReturn,
                        child: Text('Resellable return — stock increases'),
                      ),
                      DropdownMenuItem(
                        value: StockMovementType.returnDamaged,
                        child: Text('Damaged return — stock stays the same'),
                      ),
                    ],
                    onChanged:
                        _saving
                            ? null
                            : (value) => setState(
                              () =>
                                  _type =
                                      value ?? StockMovementType.customerReturn,
                            ),
                  ),
                const SizedBox(height: KgweboSpacing.md),
                KgweboTextField(
                  controller: _quantity,
                  label: 'Quantity',
                  hint: '1',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  errorText: _errors.quantity,
                  enabled: !_saving,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                ),
                if (_type.recordsIncomingCost) ...[
                  const SizedBox(height: KgweboSpacing.md),
                  KgweboTextField(
                    controller: _cost,
                    label: 'Unit cost (optional)',
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
                ],
                if (_type.requiresReason) ...[
                  const SizedBox(height: KgweboSpacing.md),
                  KgweboTextField(
                    controller: _reason,
                    label: 'Reason',
                    hint: 'Broken in storage',
                    errorText: _errors.reason,
                    enabled: !_saving,
                  ),
                ],
                const SizedBox(height: KgweboSpacing.md),
                KgweboTextField(
                  controller: _notes,
                  label: 'Notes (optional)',
                  errorText: _errors.notes,
                  enabled: !_saving,
                ),
              ],
            ),
          ),
          const SizedBox(height: KgweboSpacing.lg),
          KgweboButton(
            label: 'Save movement',
            expanded: true,
            isLoading: _saving,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }

  String _helpText(StockMovementType type) {
    return switch (type) {
      StockMovementType.received =>
        'Receiving stock increases available units. If you enter a cost, the product cost becomes a weighted average. ${_onlineCopy()}',
      StockMovementType.opening =>
        'Opening stock is the first count for this product. ${_onlineCopy()}',
      StockMovementType.customerReturn =>
        'A resellable customer return increases stock. A damaged return is recorded but does not put the item back on the shelf. Record a refund separately if money was returned. ${_onlineCopy()}',
      StockMovementType.returnDamaged =>
        'A damaged return is recorded for history. Available stock does not increase. ${_onlineCopy()}',
      StockMovementType.damaged =>
        'Damaged or lost stock reduces available units and needs a reason. ${_onlineCopy()}',
      StockMovementType.adjustmentIncrease ||
      StockMovementType.adjustmentDecrease =>
        'Manual corrections need a reason and are written to the stock ledger. ${_onlineCopy()}',
      StockMovementType.sold || StockMovementType.reversal => _onlineCopy(),
    };
  }
}
