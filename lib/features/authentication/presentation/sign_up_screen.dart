import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/validation/auth_validators.dart';
import '../../../shared/widgets/kgwebo_button.dart';
import '../../../shared/widgets/kgwebo_status_banner.dart';
import '../../../shared/widgets/kgwebo_text_field.dart';
import '../application/session_controller.dart';
import '../domain/auth_failure.dart';
import 'widgets/auth_layout.dart';
import 'widgets/password_field.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  String? _emailError;
  String? _passwordError;
  String? _confirmationError;
  String? _formError;
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final emailError = validateEmail(_email.text);
    final passwordError = validatePassword(_password.text);
    final confirmationError = validatePasswordConfirmation(
      password: _password.text,
      confirmation: _confirmation.text,
    );
    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
      _confirmationError = confirmationError;
      _formError = null;
    });
    if (emailError != null ||
        passwordError != null ||
        confirmationError != null ||
        _submitting) {
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .signUp(email: _email.text, password: _password.text);
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
    return AutofillGroup(
      child: AuthLayout(
        title: 'Create your account',
        subtitle:
            'Use an email you can check. You will confirm it with a 6-digit code. The server may still reject a weak password.',
        footer: KgweboButton(
          label: 'I already have an account',
          variant: KgweboButtonVariant.text,
          expanded: true,
          onPressed: _submitting ? null : () => context.go(AppRoutes.signIn),
        ),
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
            KgweboTextField(
              controller: _email,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              errorText: _emailError,
              enabled: !_submitting,
              autocorrect: false,
            ),
            const SizedBox(height: 16),
            PasswordField(
              controller: _password,
              label: 'Password',
              errorText: _passwordError,
              enabled: !_submitting,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
            ),
            const SizedBox(height: 16),
            PasswordField(
              controller: _confirmation,
              label: 'Confirm password',
              errorText: _confirmationError,
              enabled: !_submitting,
              onSubmitted: (_) => _submit(),
              autofillHints: const [AutofillHints.newPassword],
            ),
            const SizedBox(height: 24),
            KgweboButton(
              label: 'Create account',
              expanded: true,
              isLoading: _submitting,
              onPressed: _submitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
