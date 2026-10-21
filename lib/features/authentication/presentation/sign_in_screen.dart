import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../shared/widgets/kgwebo_button.dart';
import '../../../shared/widgets/kgwebo_status_banner.dart';
import '../../../shared/widgets/kgwebo_text_field.dart';
import '../../../core/validation/auth_validators.dart';
import '../application/session_controller.dart';
import '../domain/auth_failure.dart';
import 'widgets/auth_layout.dart';
import 'widgets/password_field.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _emailError;
  String? _passwordError;
  String? _formError;
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final emailError = validateEmail(_email.text);
    final passwordError = validatePassword(_password.text);
    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
      _formError = null;
    });
    if (emailError != null || passwordError != null || _submitting) {
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .signIn(email: _email.text, password: _password.text);
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
        title: 'Sign in',
        subtitle: 'Use the email and password for your Kgwebo account.',
        footer: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KgweboButton(
              label: 'Create an account',
              variant: KgweboButtonVariant.text,
              expanded: true,
              onPressed:
                  _submitting ? null : () => context.go(AppRoutes.signUp),
            ),
          ],
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
              onSubmitted: (_) => _submit(),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: KgweboButton(
                label: 'Forgot password?',
                variant: KgweboButtonVariant.text,
                onPressed:
                    _submitting
                        ? null
                        : () => context.go(AppRoutes.forgotPassword),
              ),
            ),
            const SizedBox(height: 8),
            KgweboButton(
              label: 'Sign in',
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
