import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/kgwebo_colors.dart';
import '../../../app/theme/kgwebo_spacing.dart';
import '../../../core/validation/onboarding_validators.dart';
import '../../../shared/widgets/kgwebo_button.dart';
import '../../../shared/widgets/kgwebo_status_banner.dart';
import '../../../shared/widgets/kgwebo_text_field.dart';
import '../../authentication/application/session_controller.dart';
import '../../authentication/domain/app_session.dart';
import '../../authentication/domain/auth_failure.dart';
import '../../authentication/presentation/widgets/auth_layout.dart';
import '../domain/onboarding_draft.dart';
import '../domain/onboarding_options.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _name = TextEditingController();
  final _openingCash = TextEditingController();
  final _description = TextEditingController();
  String _businessType = '';
  String _countryCode = 'BW';
  String _currencyCode = 'BWP';
  OnboardingFieldErrors _errors = const OnboardingFieldErrors();
  String? _formError;
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _openingCash.dispose();
    _description.dispose();
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
    );
  }

  Future<void> _submit() async {
    final errors = validateOnboardingDraft(_draft());
    setState(() {
      _errors = errors;
      _formError = null;
    });
    if (errors.hasErrors || _submitting) {
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .completeOnboarding(_draft());
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _formError = error.message);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(appSessionProvider);
    final loadError = session is AppSessionFailure ? session.message : null;

    return AuthLayout(
      title: 'Set up your business',
      subtitle:
          'Only the details needed to start. Opening cash is a starting position, not a sale.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_formError != null || loadError != null) ...[
            KgweboStatusBanner(
              tone: KgweboBannerTone.warning,
              message: _formError ?? loadError!,
            ),
            const SizedBox(height: KgweboSpacing.md),
          ],
          KgweboTextField(
            controller: _name,
            label: 'Business name',
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            errorText: _errors.name,
            enabled: !_submitting,
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
                _submitting
                    ? null
                    : (value) => setState(() => _businessType = value ?? ''),
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
                _submitting
                    ? null
                    : (value) => setState(() => _countryCode = value ?? 'BW'),
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
                _submitting
                    ? null
                    : (value) => setState(() => _currencyCode = value ?? 'BWP'),
          ),
          const SizedBox(height: KgweboSpacing.md),
          KgweboTextField(
            controller: _openingCash,
            label: 'Opening cash (optional)',
            hint: '0.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            errorText: _errors.openingCash,
            enabled: !_submitting,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
          ),
          const SizedBox(height: KgweboSpacing.xs),
          Text(
            'Leave blank for zero. This is cash already on hand, not revenue.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: KgweboColors.inkMuted),
          ),
          const SizedBox(height: KgweboSpacing.md),
          KgweboTextField(
            controller: _description,
            label: 'Description (optional)',
            textCapitalization: TextCapitalization.sentences,
            enabled: !_submitting,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: KgweboSpacing.xl),
          KgweboButton(
            label: 'Save and continue',
            expanded: true,
            isLoading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
          if (session is AppSessionFailure) ...[
            const SizedBox(height: KgweboSpacing.sm),
            KgweboButton(
              label: 'Retry loading',
              expanded: true,
              variant: KgweboButtonVariant.secondary,
              onPressed:
                  _submitting
                      ? null
                      : () =>
                          ref
                              .read(sessionControllerProvider.notifier)
                              .retryOnboardingLoad(),
            ),
          ],
        ],
      ),
    );
  }
}
