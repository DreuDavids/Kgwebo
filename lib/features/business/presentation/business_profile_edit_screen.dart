import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/kgwebo_colors.dart';
import '../../../app/theme/kgwebo_spacing.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/validation/onboarding_validators.dart';
import '../../../shared/widgets/kgwebo_button.dart';
import '../../../shared/widgets/kgwebo_soft_card.dart';
import '../../../shared/widgets/kgwebo_empty_state.dart';
import '../../../shared/widgets/kgwebo_loading_state.dart';
import '../../../shared/widgets/kgwebo_status_banner.dart';
import '../../../shared/widgets/kgwebo_text_field.dart';
import '../../onboarding/domain/onboarding_draft.dart';
import '../../onboarding/domain/onboarding_options.dart';
import '../application/business_profile_controller.dart';

class BusinessProfileEditScreen extends ConsumerStatefulWidget {
  const BusinessProfileEditScreen({super.key});

  @override
  ConsumerState<BusinessProfileEditScreen> createState() =>
      _BusinessProfileEditScreenState();
}

class _BusinessProfileEditScreenState
    extends ConsumerState<BusinessProfileEditScreen> {
  final _name = TextEditingController();
  final _openingCash = TextEditingController();
  final _description = TextEditingController();
  final _contactPhone = TextEditingController();
  String _businessType = '';
  String _countryCode = 'BW';
  String _currencyCode = 'BWP';
  DateTime? _startedOn;
  OnboardingFieldErrors _errors = const OnboardingFieldErrors();
  bool _hydrated = false;
  bool _allowPop = false;
  String? _hydratedBusinessId;

  @override
  void dispose() {
    _name.dispose();
    _openingCash.dispose();
    _description.dispose();
    _contactPhone.dispose();
    super.dispose();
  }

  OnboardingDraft _draft() {
    return OnboardingDraft(
      name: _name.text,
      businessType: _businessType,
      countryCode: _countryCode,
      currencyCode: _currencyCode,
      openingCashText: _openingCash.text,
      description: _description.text,
      startedOn: _startedOn,
      contactPhone: _contactPhone.text,
    );
  }

  bool get _isDirty {
    final profile = ref.read(businessProfileControllerProvider).profile;
    if (profile == null) {
      return false;
    }
    final original = OnboardingDraft.fromProfile(profile);
    final current = _draft();
    return original.name != current.name.trim() ||
        original.businessType != current.businessType ||
        original.countryCode != current.countryCode ||
        original.currencyCode != current.currencyCode ||
        original.openingBalanceMinor != current.openingBalanceMinor ||
        original.description.trim() != current.description.trim() ||
        original.contactPhone.trim() != current.contactPhone.trim() ||
        !_sameDate(original.startedOn, current.startedOn);
  }

  bool _sameDate(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return a == b;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _hydrateIfNeeded(BusinessProfileViewState state) {
    final profile = state.profile;
    if (profile == null || _hydratedBusinessId == profile.id) {
      return;
    }
    final draft = OnboardingDraft.fromProfile(profile);
    _name.text = draft.name;
    _openingCash.text = draft.openingCashText;
    _description.text = draft.description;
    _contactPhone.text = draft.contactPhone;
    _businessType = draft.businessType;
    _countryCode = draft.countryCode;
    _currencyCode = draft.currencyCode;
    _startedOn = draft.startedOn;
    _hydrated = true;
    _hydratedBusinessId = profile.id;
  }

  Future<bool> _confirmDiscard() async {
    if (!_isDirty) {
      return true;
    }
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Discard unsaved changes?'),
            content: const Text(
              'Your edits have not been saved. Leave without saving?',
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

  void _leave(NavigatorState navigator) {
    setState(() => _allowPop = true);
    navigator.pop();
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
    final errors = validateOnboardingDraft(_draft());
    setState(() => _errors = errors);
    if (errors.hasErrors) {
      return;
    }
    final navigator = Navigator.of(context);
    final controller = ref.read(businessProfileControllerProvider.notifier);
    await controller.save(_draft());
    if (!mounted) {
      return;
    }
    final state = ref.read(businessProfileControllerProvider);
    if (state.success != null) {
      _leave(navigator);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startedOn ?? now,
      firstDate: DateTime(1990),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _startedOn = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(businessProfileControllerProvider);
    if (!_hydrated && state.profile != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        setState(() => _hydrateIfNeeded(state));
      });
    }
    final saving = state.saving;

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
          title: const Text('Edit business'),
          actions: [
            TextButton(
              onPressed: saving ? null : _cancel,
              child: const Text('Cancel'),
            ),
          ],
        ),
        body: SafeArea(
          child: KgweboFilledBody(child: _buildBody(state, saving)),
        ),
      ),
    );
  }

  Widget _buildBody(BusinessProfileViewState state, bool saving) {
    if (state.isPreview) {
      return const KgweboEmptyState(
        icon: Icons.storefront_outlined,
        title: 'Preview cannot edit a live business',
        message: 'Sign in to change a saved business profile.',
      );
    }
    if (state.loading && state.profile == null) {
      return const KgweboLoadingState(message: 'Loading your business');
    }
    if (state.profile == null) {
      return KgweboEmptyState(
        icon: Icons.storefront_outlined,
        title: 'Nothing to edit',
        message:
            state.error ??
            'The business profile could not be loaded. Retry and try again.',
        actionLabel: 'Retry',
        onAction:
            () =>
                ref.read(businessProfileControllerProvider.notifier).refresh(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        KgweboSpacing.md,
        KgweboSpacing.md,
        KgweboSpacing.md,
        KgweboSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.error != null) ...[
            KgweboStatusBanner(
              tone: KgweboBannerTone.warning,
              message: state.error!,
            ),
            const SizedBox(height: KgweboSpacing.md),
          ],
          KgweboSoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                KgweboTextField(
                  controller: _name,
                  label: 'Business name',
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  errorText: _errors.name,
                  enabled: !saving,
                ),
                const SizedBox(height: KgweboSpacing.md),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _businessType.isEmpty ? null : _businessType,
                  decoration: InputDecoration(
                    labelText: 'Business type',
                    errorText: _errors.businessType,
                  ),
                  items: [
                    for (final type in OnboardingOptions.businessTypes)
                      DropdownMenuItem(value: type, child: Text(type)),
                  ],
                  onChanged:
                      saving
                          ? null
                          : (value) =>
                              setState(() => _businessType = value ?? ''),
                ),
                const SizedBox(height: KgweboSpacing.md),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _countryCode,
                  decoration: const InputDecoration(labelText: 'Country'),
                  items: [
                    for (final country in OnboardingOptions.countries)
                      DropdownMenuItem(
                        value: country.code,
                        child: Text(country.label),
                      ),
                  ],
                  onChanged:
                      saving
                          ? null
                          : (value) =>
                              setState(() => _countryCode = value ?? 'BW'),
                ),
                const SizedBox(height: KgweboSpacing.md),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _currencyCode,
                  decoration: const InputDecoration(labelText: 'Currency'),
                  items: [
                    for (final currency in OnboardingOptions.currencies)
                      DropdownMenuItem(
                        value: currency.code,
                        child: Text(currency.label),
                      ),
                  ],
                  onChanged:
                      saving
                          ? null
                          : (value) =>
                              setState(() => _currencyCode = value ?? 'BWP'),
                ),
                const SizedBox(height: KgweboSpacing.md),
                KgweboTextField(
                  controller: _openingCash,
                  label: 'Opening / starting cash',
                  hint: '0.00',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  errorText: _errors.openingCash,
                  enabled: !saving,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                ),
                const SizedBox(height: KgweboSpacing.xs),
                Text(
                  'Cash already on hand when you started tracking. This is not a sale or revenue.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: KgweboColors.inkMuted),
                ),
                const SizedBox(height: KgweboSpacing.md),
                KgweboTextField(
                  controller: _description,
                  label: 'Description (optional)',
                  textCapitalization: TextCapitalization.sentences,
                  enabled: !saving,
                ),
                const SizedBox(height: KgweboSpacing.md),
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Business start date',
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _startedOn == null
                              ? 'Not set'
                              : DateFormat.yMMMd().format(_startedOn!),
                        ),
                      ),
                      TextButton(
                        onPressed: saving ? null : _pickDate,
                        child: const Text('Choose'),
                      ),
                      if (_startedOn != null)
                        TextButton(
                          onPressed:
                              saving
                                  ? null
                                  : () => setState(() => _startedOn = null),
                          child: const Text('Clear'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: KgweboSpacing.md),
                KgweboTextField(
                  controller: _contactPhone,
                  label: 'Contact phone (optional)',
                  keyboardType: TextInputType.phone,
                  enabled: !saving,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _save(),
                ),
              ],
            ),
          ),
          const SizedBox(height: KgweboSpacing.xl),
          KgweboButton(
            label: saving ? 'Saving' : 'Save',
            expanded: true,
            isLoading: saving,
            onPressed: saving ? null : _save,
          ),
          const SizedBox(height: KgweboSpacing.sm),
          KgweboButton(
            label: 'Cancel',
            expanded: true,
            variant: KgweboButtonVariant.secondary,
            onPressed: saving ? null : _cancel,
          ),
        ],
      ),
    );
  }
}
