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

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  String? _emailError;
  String? _formError;
  bool _submitting = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final emailError = validateEmail(_email.text);
    setState(() {
      _emailError = emailError;
      _formError = null;
    });
    if (emailError != null || _submitting) {
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .requestPasswordReset(_email.text);
      if (!mounted) {
        return;
      }
      setState(() => _sent = true);
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
      title: 'Reset your password',
      subtitle:
          'We will send a recovery link to this email if an account exists. The link opens Kgwebo so you can choose a new password.',
      footer: KgweboButton(
        label: 'Back to sign in',
        variant: KgweboButtonVariant.text,
        expanded: true,
        onPressed: () => context.go(AppRoutes.signIn),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_sent)
            const KgweboStatusBanner(
              tone: KgweboBannerTone.info,
              message:
                  'If that email is registered, a recovery link is on its way. It does not sign anyone else in.',
            )
          else ...[
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
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              errorText: _emailError,
              enabled: !_submitting,
              autocorrect: false,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            KgweboButton(
              label: 'Send reset link',
              expanded: true,
              isLoading: _submitting,
              onPressed: _submitting ? null : _submit,
            ),
          ],
        ],
      ),
    );
  }
}
