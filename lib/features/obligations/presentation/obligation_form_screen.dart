import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/kgwebo_colors.dart';
import '../../../app/theme/kgwebo_spacing.dart';
import '../../../core/finance/business_calendar.dart';
import '../../../core/finance/cash_outlook.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../shared/widgets/kgwebo_button.dart';
import '../../../shared/widgets/kgwebo_empty_state.dart';
import '../../../shared/widgets/kgwebo_soft_card.dart';
import '../../../shared/widgets/kgwebo_status_banner.dart';
import '../../../shared/widgets/kgwebo_text_field.dart';
import '../../authentication/application/session_controller.dart';
import '../../authentication/domain/app_session.dart';
import '../../authentication/domain/auth_failure.dart';
import '../application/obligation_tick.dart';
import '../application/obligation_validators.dart';
import '../domain/obligation_categories.dart';
import '../domain/obligation_draft.dart';

class ObligationFormScreen extends ConsumerStatefulWidget {
  const ObligationFormScreen({super.key, this.obligationId});

  final String? obligationId;

  @override
  ConsumerState<ObligationFormScreen> createState() =>
      _ObligationFormScreenState();
}

class _ObligationFormScreenState extends ConsumerState<ObligationFormScreen> {
  final _title = TextEditingController();
  final _amount = TextEditingController();
  final _notes = TextEditingController();
  late final String _idempotencyKey;
  late DateTime _dueOn;
  late String _category;
  CommitmentStatus _status = CommitmentStatus.unpaid;
  ObligationFieldErrors _errors = const ObligationFieldErrors();
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
    _dueOn = DateTime(now.year, now.month, now.day);
    _category = ObligationCategories.defaultCode();
    _existingId = widget.obligationId;
    if (widget.obligationId != null) {
      _loadingExisting = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
    } else {
      _hydrated = true;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    final session = ref.read(appSessionProvider);
    if (session is! AppSessionReady) {
      setState(() {
        _loadingExisting = false;
        _error = 'Sign in to edit a saved commitment.';
      });
      return;
    }
    try {
      final existing = await ref
          .read(obligationRepositoryProvider)
          .findById(
            ownerId: session.user.id,
            businessId: session.business.id,
            obligationId: widget.obligationId!,
          );
      if (!mounted) {
        return;
      }
      if (existing == null) {
        setState(() {
          _loadingExisting = false;
          _error = 'This commitment could not be loaded.';
        });
        return;
      }
      _title.text = existing.title;
      _amount.text = _amountText(existing.amountMinor);
      _notes.text = existing.notes ?? '';
      setState(() {
        _dueOn = DateTime(
          existing.dueOn.year,
          existing.dueOn.month,
          existing.dueOn.day,
        );
        _category = existing.category;
        _status = existing.status;
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

  ObligationDraft _draft() {
    return ObligationDraft(
      title: _title.text,
      amountText: _amount.text,
      dueOn: _dueOn,
      category: _category,
      status: _status,
      notes: _notes.text,
      idempotencyKey: _idempotencyKey,
      existingId: _existingId,
    );
  }

  bool get _isDirty {
    if (!_hydrated) {
      return false;
    }
    return _title.text.trim().isNotEmpty || _amount.text.trim().isNotEmpty;
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
              'This commitment has not been saved. Leave without saving?',
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
    final errors = validateObligationDraft(_draft());
    setState(() {
      _errors = errors;
      _error = null;
    });
    if (errors.hasErrors) {
      return;
    }
    final session = ref.read(appSessionProvider);
    if (session is! AppSessionReady) {
      setState(() => _error = 'Sign in to save this commitment.');
      return;
    }
    setState(() => _saving = true);
    try {
      final repository = ref.read(obligationRepositoryProvider);
      if (_isEdit) {
        await repository.update(
          ownerId: session.user.id,
          businessId: session.business.id,
          currencyCode: session.business.currencyCode,
          draft: _draft(),
        );
      } else {
        final saved = await repository.create(
          ownerId: session.user.id,
          businessId: session.business.id,
          currencyCode: session.business.currencyCode,
          draft: _draft(),
        );
        if (saved.pendingSync && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Saved on this device. Waiting to sync. This is not a recorded expense.',
              ),
            ),
          );
        }
      }
      if (!mounted) {
        return;
      }
      bumpObligationTick(ref);
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
      initialDate: _dueOn,
      firstDate: DateTime(1990),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _dueOn = DateTime(picked.year, picked.month, picked.day));
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
          title: Text(_isEdit ? 'Edit bill' : 'Add a bill'),
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
        icon: Icons.event_outlined,
        title: 'Preview cannot save bills',
        message: 'Sign in to record bills you still need to pay.',
      );
    }
    if (session is! AppSessionReady) {
      return const KgweboEmptyState(
        icon: Icons.lock_outline,
        title: 'Sign in to continue',
        message: 'Bills are saved to your business only.',
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
          KgweboStatusBanner(
            tone: KgweboBannerTone.info,
            message:
                _isEdit
                    ? 'Edits need a live connection. Unpaid bills do not reduce cash until you pay them.'
                    : 'Unpaid bills do not reduce cash until you pay them. If you are offline, this bill can wait on this device.',
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
                  controller: _title,
                  label: 'What is this for?',
                  hint: 'Shop rent',
                  textCapitalization: TextCapitalization.sentences,
                  errorText: _errors.title,
                  enabled: !_saving,
                ),
                const SizedBox(height: KgweboSpacing.md),
                KgweboTextField(
                  controller: _amount,
                  label: 'Amount in ${session.business.currencyCode}',
                  hint: '0.00',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
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
                    for (final category in ObligationCategories.all)
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
                  decoration: const InputDecoration(labelText: 'Due date'),
                  child: InkWell(
                    onTap: _saving ? null : _pickDate,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(DateFormat.yMMMEd().format(_dueOn)),
                    ),
                  ),
                ),
                const SizedBox(height: KgweboSpacing.md),
                DropdownButtonFormField<CommitmentStatus>(
                  isExpanded: true,
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(
                      value: CommitmentStatus.unpaid,
                      child: Text('Unpaid'),
                    ),
                    DropdownMenuItem(
                      value: CommitmentStatus.paid,
                      child: Text('Paid'),
                    ),
                    DropdownMenuItem(
                      value: CommitmentStatus.cancelled,
                      child: Text('Cancelled'),
                    ),
                  ],
                  onChanged:
                      _saving
                          ? null
                          : (value) =>
                              setState(() => _status = value ?? _status),
                ),
                const SizedBox(height: KgweboSpacing.xs),
                Text(
                  _status == CommitmentStatus.paid
                      ? 'Marking paid does not record an expense or change cash. Record an expense if money left the business.'
                      : 'Unpaid bills stay out of cash until you pay them.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: KgweboColors.inkMuted),
                ),
                const SizedBox(height: KgweboSpacing.md),
                KgweboTextField(
                  controller: _notes,
                  label: 'Note (optional)',
                  textCapitalization: TextCapitalization.sentences,
                  enabled: !_saving,
                  errorText: _errors.notes,
                ),
              ],
            ),
          ),
          const SizedBox(height: KgweboSpacing.xl),
          KgweboButton(
            label: _isEdit ? 'Save changes' : 'Save bill',
            expanded: true,
            isLoading: _saving,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}
