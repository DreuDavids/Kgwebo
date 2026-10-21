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
import 'widgets/otp_code_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _otp = TextEditingController();
  String? _emailError;
  String? _otpError;
  String? _formError;
  bool _submitting = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    _otp.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
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

  Future<void> _verify() async {
    final otpError = validateOtp(_otp.text);
    setState(() {
      _otpError = otpError;
      _formError = null;
    });
    if (otpError != null || _submitting) {
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .verifyRecoveryOtp(email: _email.text, token: _otp.text);
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
          _sent
              ? 'Enter the 6-character code sent to ${_email.text.trim()} if that email is registered. Then choose a new password.'
              : 'We will send a 6-character code to this email if an account exists. Enter the code in Kgwebo to choose a new password.',
      footer: KgweboButton(
        label: 'Back to sign in',
        variant: KgweboButtonVariant.text,
        expanded: true,
        onPressed: () => context.go(AppRoutes.signIn),
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
          if (_sent) ...[
            const KgweboStatusBanner(
              tone: KgweboBannerTone.info,
              message:
                  'If that email is registered, a 6-character code is on its way. It does not sign anyone else in.',
            ),
            const SizedBox(height: 16),
            OtpCodeField(
              controller: _otp,
              errorText: _otpError,
              enabled: !_submitting,
              onSubmitted: (_) => _verify(),
            ),
            const SizedBox(height: 24),
            KgweboButton(
              label: 'Verify code',
              expanded: true,
              isLoading: _submitting,
              onPressed: _submitting ? null : _verify,
            ),
            const SizedBox(height: 8),
            KgweboButton(
              label: 'Resend code',
              variant: KgweboButtonVariant.text,
              expanded: true,
              onPressed: _submitting ? null : _sendCode,
            ),
          ] else ...[
            KgweboTextField(
              controller: _email,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              errorText: _emailError,
              enabled: !_submitting,
              autocorrect: false,
              onSubmitted: (_) => _sendCode(),
            ),
            const SizedBox(height: 24),
            KgweboButton(
              label: 'Send reset code',
              expanded: true,
              isLoading: _submitting,
              onPressed: _submitting ? null : _sendCode,
            ),
          ],
        ],
      ),
    );
  }
}
