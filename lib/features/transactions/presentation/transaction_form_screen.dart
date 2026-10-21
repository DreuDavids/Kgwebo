import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/kgwebo_colors.dart';
import '../../../app/theme/kgwebo_spacing.dart';
import '../../../core/finance/business_calendar.dart';
import '../../../core/finance/ledger_entry.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../shared/widgets/kgwebo_button.dart';
import '../../../shared/widgets/kgwebo_soft_card.dart';
import '../../../shared/widgets/kgwebo_empty_state.dart';
import '../../../shared/widgets/kgwebo_status_banner.dart';
import '../../../shared/widgets/kgwebo_text_field.dart';
import '../../authentication/application/session_controller.dart';
import '../../authentication/domain/app_session.dart';
import '../../authentication/domain/auth_failure.dart';
import '../application/transaction_tick.dart';
import '../application/transaction_validators.dart';
import '../domain/payment_method.dart';
import '../domain/transaction_categories.dart';
import '../domain/transaction_draft.dart';
import 'widgets/transaction_type_style.dart';

class TransactionFormScreen extends ConsumerStatefulWidget {
  const TransactionFormScreen({
    super.key,
    required this.type,
    this.transactionId,
  });

  final MoneyMovementType type;
  final String? transactionId;

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _amount = TextEditingController();
  final _description = TextEditingController();
  late final String _idempotencyKey;
  late DateTime _occurredOn;
  late String _category;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  PaymentStatus _paymentStatus = PaymentStatus.paid;
  TransactionFieldErrors _errors = const TransactionFieldErrors();
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
    _idempotencyKey = const Uuid().v4();
    final now = BusinessCalendar.gaboroneWallTime(DateTime.now().toUtc());
    _occurredOn = DateTime(now.year, now.month, now.day);
    _category = TransactionCategories.defaultCode(widget.type);
    _existingId = widget.transactionId;
    if (widget.transactionId != null) {
      _loadingExisting = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
    } else {
      _hydrated = true;
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    final session = ref.read(appSessionProvider);
    if (session is! AppSessionReady) {
      setState(() {
        _loadingExisting = false;
        _error = 'Sign in to edit a saved transaction.';
      });
      return;
    }
    try {
      final existing = await ref
          .read(transactionRepositoryProvider)
          .findById(
            ownerId: session.user.id,
            businessId: session.business.id,
            transactionId: widget.transactionId!,
          );
      if (!mounted) {
        return;
      }
      if (existing == null || existing.type != widget.type) {
        setState(() {
          _loadingExisting = false;
          _error = 'This transaction could not be loaded.';
        });
        return;
      }
      final wall = BusinessCalendar.gaboroneWallTime(existing.occurredAt);
      _amount.text = _amountText(existing.amountMinor);
      _description.text = existing.description ?? '';
      setState(() {
        _occurredOn = DateTime(wall.year, wall.month, wall.day);
        _category = existing.category;
        _paymentMethod = existing.paymentMethod;
        _paymentStatus = existing.paymentStatus;
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

  String _amountText(int minor) {
    final whole = minor ~/ 100;
    final fraction = (minor % 100).toString().padLeft(2, '0');
    return '$whole.$fraction';
  }

  TransactionDraft _draft() {
    return TransactionDraft(
      type: widget.type,
      amountText: _amount.text,
      occurredOn: _occurredOn,
      category: _category,
      description: _description.text,
      paymentMethod: _paymentMethod,
      paymentStatus: _paymentStatus,
      idempotencyKey: _idempotencyKey,
      existingId: _existingId,
    );
  }

  bool get _isDirty {
    if (!_hydrated) {
      return false;
    }
    return _amount.text.trim().isNotEmpty ||
        _description.text.trim().isNotEmpty;
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
              'This transaction has not been saved. Leave without saving?',
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
    final errors = validateTransactionDraft(_draft());
    setState(() {
      _errors = errors;
      _error = null;
    });
    if (errors.hasErrors) {
      return;
    }
    final session = ref.read(appSessionProvider);
    if (session is! AppSessionReady) {
      setState(() => _error = 'Sign in to save this transaction.');
      return;
    }
    setState(() => _saving = true);
    try {
      final repository = ref.read(transactionRepositoryProvider);
      if (_isEdit) {
        await repository.update(
          ownerId: session.user.id,
          businessId: session.business.id,
          currencyCode: session.business.currencyCode,
          draft: _draft(),
        );
      } else {
        await repository.create(
          ownerId: session.user.id,
          businessId: session.business.id,
          currencyCode: session.business.currencyCode,
          draft: _draft(),
        );
      }
      if (!mounted) {
        return;
      }
      bumpTransactionTick(ref);
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _occurredOn,
      firstDate: DateTime(1990),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(
        () => _occurredOn = DateTime(picked.year, picked.month, picked.day),
      );
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
          title: Text(
            _isEdit ? editTitleForType(widget.type) : titleForType(widget.type),
          ),
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
        icon: Icons.receipt_long_outlined,
        title: 'Preview cannot save transactions',
        message:
            'Sign in to record sales and expenses against your business. Demo figures are never mixed with live records.',
      );
    }
    if (session is! AppSessionReady) {
      return const KgweboEmptyState(
        icon: Icons.lock_outline,
        title: 'Sign in to continue',
        message: 'Transactions are saved to your authorised business only.',
      );
    }
    if (_loadingExisting) {
      return const Center(child: CircularProgressIndicator());
    }

    final categories = TransactionCategories.forType(widget.type);
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
            message: _typeHelp(widget.type),
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
                  controller: _amount,
                  label: 'Amount in ${session.business.currencyCode}',
                  hint: '0.00',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  errorText: _errors.amount,
                  enabled: !_saving,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                ),
                const SizedBox(height: KgweboSpacing.md),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _category,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    errorText: _errors.category,
                  ),
                  items: [
                    for (final category in categories)
                      DropdownMenuItem(
                        value: category.code,
                        child: Text(category.label),
                      ),
                  ],
                  onChanged:
                      _saving
                          ? null
                          : (value) =>
                              setState(() => _category = value ?? _category),
                ),
                const SizedBox(height: KgweboSpacing.md),
                InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date'),
                  child: InkWell(
                    onTap: _saving ? null : _pickDate,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(DateFormat.yMMMEd().format(_occurredOn)),
                    ),
                  ),
                ),
                const SizedBox(height: KgweboSpacing.md),
                DropdownButtonFormField<PaymentMethod>(
                  isExpanded: true,
                  value: _paymentMethod,
                  decoration: const InputDecoration(
                    labelText: 'Payment method',
                  ),
                  items: [
                    for (final method in PaymentMethod.values)
                      DropdownMenuItem(
                        value: method,
                        child: Text(method.label),
                      ),
                  ],
                  onChanged:
                      _saving
                          ? null
                          : (value) => setState(
                            () => _paymentMethod = value ?? _paymentMethod,
                          ),
                ),
                const SizedBox(height: KgweboSpacing.md),
                DropdownButtonFormField<PaymentStatus>(
                  isExpanded: true,
                  value: _paymentStatus,
                  decoration: const InputDecoration(
                    labelText: 'Payment status',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: PaymentStatus.paid,
                      child: Text('Paid'),
                    ),
                    DropdownMenuItem(
                      value: PaymentStatus.unpaid,
                      child: Text('Unpaid'),
                    ),
                  ],
                  onChanged:
                      _saving
                          ? null
                          : (value) => setState(
                            () => _paymentStatus = value ?? _paymentStatus,
                          ),
                ),
                const SizedBox(height: KgweboSpacing.xs),
                Text(
                  _paymentHelp(widget.type, _paymentStatus),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: KgweboColors.inkMuted),
                ),
                const SizedBox(height: KgweboSpacing.md),
                KgweboTextField(
                  controller: _description,
                  label: 'Note (optional)',
                  textCapitalization: TextCapitalization.sentences,
                  enabled: !_saving,
                  errorText: _errors.description,
                ),
              ],
            ),
          ),
          const SizedBox(height: KgweboSpacing.xl),
          KgweboButton(
            label:
                _isEdit
                    ? 'Save changes'
                    : 'Save ${TransactionTypeStyle.label(widget.type).toLowerCase()}',
            expanded: true,
            isLoading: _saving,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }

  String _typeHelp(MoneyMovementType type) {
    return switch (type) {
      MoneyMovementType.sale =>
        'This is a recorded sale. It is not automatically cash received unless you mark it paid.',
      MoneyMovementType.expense =>
        'This is an operating expense. Unpaid bills stay in the period total but do not reduce current cash.',
      MoneyMovementType.refund =>
        'A customer refund reduces recorded sales. Paid refunds also reduce current cash.',
      MoneyMovementType.ownerContribution =>
        'Owner money put into the business increases cash. It is not a sale.',
      MoneyMovementType.ownerWithdrawal =>
        'Owner money taken out of the business reduces cash. It is not an operating expense.',
    };
  }

  String _paymentHelp(MoneyMovementType type, PaymentStatus status) {
    if (status == PaymentStatus.paid) {
      return switch (type) {
        MoneyMovementType.sale || MoneyMovementType.ownerContribution =>
          'Paid amounts are included in current recorded cash.',
        MoneyMovementType.expense ||
        MoneyMovementType.refund ||
        MoneyMovementType
            .ownerWithdrawal => 'Paid amounts reduce current recorded cash.',
      };
    }
    return switch (type) {
      MoneyMovementType.sale =>
        'Unpaid means the customer has not paid yet. It counts as a recorded sale, not as cash received.',
      MoneyMovementType.expense =>
        'Unpaid means this bill is not paid yet. It counts as an operating cost, not a cash outflow.',
      MoneyMovementType.refund =>
        'An unpaid refund reduces recorded sales but does not yet reduce cash.',
      MoneyMovementType.ownerContribution ||
      MoneyMovementType.ownerWithdrawal =>
        'Unpaid owner movements are recorded but do not change current cash until marked paid.',
    };
  }
}
