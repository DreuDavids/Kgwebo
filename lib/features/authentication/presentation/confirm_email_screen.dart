import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/validation/auth_validators.dart';
import '../../../shared/widgets/kgwebo_button.dart';
import '../../../shared/widgets/kgwebo_status_banner.dart';
import '../application/session_controller.dart';
import '../domain/app_session.dart';
import '../domain/auth_failure.dart';
import 'widgets/auth_layout.dart';
import 'widgets/otp_code_field.dart';

class ConfirmEmailScreen extends ConsumerStatefulWidget {
  const ConfirmEmailScreen({super.key});

  @override
  ConsumerState<ConfirmEmailScreen> createState() => _ConfirmEmailScreenState();
}

class _ConfirmEmailScreenState extends ConsumerState<ConfirmEmailScreen> {
  final _otp = TextEditingController();
  bool _submitting = false;
  String? _otpError;
  String? _message;
  String? _error;

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  String _emailFor(AppSession session) {
    return session is AppSessionNeedsEmailConfirmation
        ? session.email
        : 'your email';
  }

  String? _confirmationEmail() {
    final session = ref.read(appSessionProvider);
    if (session is! AppSessionNeedsEmailConfirmation) {
      return null;
    }
    final email = session.email.trim();
    return email.isEmpty ? null : email;
  }

  Future<void> _verify() async {
    final email = _confirmationEmail();
    final otpError = validateOtp(_otp.text);
    setState(() {
      _otpError = otpError;
      _error =
          email == null
              ? 'Enter this screen from sign-up or sign-in so we know which email to confirm.'
              : null;
      _message = null;
    });
    if (email == null || otpError != null || _submitting) {
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .verifySignupOtp(email: email, token: _otp.text);
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = error.message);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _resend() async {
    final email = _confirmationEmail();
    if (_submitting) {
      return;
    }
    setState(() {
      _submitting = true;
      _error =
          email == null
              ? 'Enter this screen from sign-up or sign-in so we know which email to confirm.'
              : null;
      _message = null;
    });
    if (email == null) {
      setState(() => _submitting = false);
      return;
    }
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .resendSignupEmail(email);
      if (!mounted) {
        return;
      }
      setState(() => _message = 'A new 6-character code is on its way.');
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = error.message);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(appSessionProvider);
    final email = _emailFor(session);

    return AuthLayout(
      title: 'Confirm your email',
      subtitle:
          'Enter the 6-character code sent to $email. It expires, so request a new one if it does not arrive in time.',
      footer: KgweboButton(
        label: 'Back to sign in',
        variant: KgweboButtonVariant.text,
        expanded: true,
        onPressed: () => context.go(AppRoutes.signIn),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null)
            KgweboStatusBanner(
              tone: KgweboBannerTone.warning,
              message: _error!,
            ),
          if (_message != null)
            KgweboStatusBanner(tone: KgweboBannerTone.info, message: _message!),
          if (_error != null || _message != null) const SizedBox(height: 16),
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
            onPressed: _submitting ? null : _resend,
          ),
        ],
      ),
    );
  }
}
