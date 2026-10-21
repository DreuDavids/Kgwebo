import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/validation/auth_validators.dart';
import '../../../shared/widgets/kgwebo_button.dart';
import '../../../shared/widgets/kgwebo_status_banner.dart';
import '../application/session_controller.dart';
import '../domain/auth_failure.dart';
import 'widgets/auth_layout.dart';
import 'widgets/password_field.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  String? _passwordError;
  String? _confirmationError;
  String? _formError;
  bool _submitting = false;

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final passwordError = validatePassword(_password.text);
    final confirmationError = validatePasswordConfirmation(
      password: _password.text,
      confirmation: _confirmation.text,
    );
    setState(() {
      _passwordError = passwordError;
      _confirmationError = confirmationError;
      _formError = null;
    });
    if (passwordError != null || confirmationError != null || _submitting) {
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .updatePassword(_password.text);
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
    return AuthLayout(
      title: 'Choose a new password',
      subtitle:
          'This screen is only used after a valid recovery code. Your previous password stops working once this save succeeds.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_formError != null) ...[
            KgweboStatusBanner(
              tone: KgweboBannerTone.warning,
              message: _formError!,
            ),
            const SizedBox(height: 16),
          ],
          PasswordField(
            controller: _password,
            label: 'New password',
            errorText: _passwordError,
            enabled: !_submitting,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
          ),
          const SizedBox(height: 16),
          PasswordField(
            controller: _confirmation,
            label: 'Confirm new password',
            errorText: _confirmationError,
            enabled: !_submitting,
            onSubmitted: (_) => _submit(),
            autofillHints: const [AutofillHints.newPassword],
          ),
          const SizedBox(height: 24),
          KgweboButton(
            label: 'Save password',
            expanded: true,
            isLoading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
    );
  }
}
